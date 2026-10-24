import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.GraphicsEnvironment;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.Arrays;
import java.util.List;

// Kept at Java 8 syntax: the same compiled class runs on every image from 8 to 25.
public class Smoke {
    private static int failures = 0;

    public static void main(String[] args) {
        System.out.println("java " + System.getProperty("java.version")
                + " (" + System.getProperty("java.vendor") + ", " + System.getProperty("os.arch") + ")");

        check("fonts: fontconfig families", Smoke::fontFamilies);
        check("fonts: render text", Smoke::renderText);
        check("jni: sqlite-jdbc", Smoke::sqlite);
        check("jni: netty epoll", Smoke::nettyEpoll);

        if (failures > 0) {
            System.out.println("SMOKE FAILED: " + failures + " check(s)");
            System.exit(1);
        }
        System.out.println("SMOKE OK");
    }

    interface Check {
        String run() throws Throwable;
    }

    private static void check(String name, Check c) {
        try {
            System.out.println("PASS " + name + ": " + c.run());
        } catch (Throwable t) {
            failures++;
            System.out.println("FAIL " + name + ": " + t);
            Throwable cause = t.getCause();
            while (cause != null) {
                System.out.println("     caused by: " + cause);
                cause = cause.getCause();
            }
        }
    }

    private static String fontFamilies() {
        List<String> families = Arrays.asList(
                GraphicsEnvironment.getLocalGraphicsEnvironment().getAvailableFontFamilyNames());
        if (!families.contains("DejaVu Sans")) {
            throw new IllegalStateException("DejaVu Sans missing, found " + families);
        }
        return families.size() + " families";
    }

    // Drawing goes through libfontmanager/libfreetype, which is where a headless
    // JRE with missing native font libraries actually breaks.
    private static String renderText() {
        BufferedImage img = new BufferedImage(200, 50, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        g.setColor(Color.WHITE);
        g.setFont(new Font("DejaVu Sans", Font.PLAIN, 24));
        g.drawString("Hello", 5, 35);
        g.dispose();
        int lit = 0;
        for (int x = 0; x < img.getWidth(); x++) {
            for (int y = 0; y < img.getHeight(); y++) {
                if ((img.getRGB(x, y) & 0xFFFFFF) != 0) {
                    lit++;
                }
            }
        }
        if (lit == 0) {
            throw new IllegalStateException("drawString painted nothing");
        }
        return lit + " pixels drawn";
    }

    private static String sqlite() throws Exception {
        Class.forName("org.sqlite.JDBC");
        try (Connection c = DriverManager.getConnection("jdbc:sqlite::memory:");
             ResultSet rs = c.createStatement().executeQuery("select sqlite_version()")) {
            rs.next();
            return "sqlite " + rs.getString(1);
        }
    }

    private static String nettyEpoll() throws Exception {
        Class<?> epoll = Class.forName("io.netty.channel.epoll.Epoll");
        Method isAvailable = epoll.getMethod("isAvailable");
        if (!(Boolean) isAvailable.invoke(null)) {
            Throwable cause = (Throwable) epoll.getMethod("unavailabilityCause").invoke(null);
            throw new IllegalStateException("epoll unavailable", cause);
        }
        return "available";
    }
}
