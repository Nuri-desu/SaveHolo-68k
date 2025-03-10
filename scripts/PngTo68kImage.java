package scripts;

import java.awt.image.BufferedImage;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import javax.imageio.ImageIO;

public class PngTo68kImage {
    public static void main(String[] args){
        if (args.length != 1) {
            System.err.println("acuerdate de poner bien el archivo!!!!!!!!");
            return;
        }
        
        String pngImageName = args[0];

        BufferedImage pngImage = null;
        try {
            pngImage = ImageIO.read(new File("png images/"+pngImageName));
        } catch (Exception e) {
            System.err.println("ESCRIBE BIEN EL NOMBRE!!!!!!" + '\n' + pngImageName + '\n' + e.getMessage());
        }

        try {
            write68kImage(pngImage,pngImageName);
        } catch (Exception e) {
            System.err.println("no");
        }
    }

    private static void write68kImage(BufferedImage pngImage, String pngImageName) throws Exception{
        char [] pngImageNameCharArr = pngImageName.toCharArray();

        pngImageNameCharArr[pngImageNameCharArr.length -3] = '6';
        pngImageNameCharArr[pngImageNameCharArr.length -2] = '8';
        pngImageNameCharArr[pngImageNameCharArr.length -1] = 'k';

        String mot68kImageName = String.valueOf(pngImageNameCharArr);

        DataOutputStream wr = new DataOutputStream(new FileOutputStream(new File("68k images/"+mot68kImageName+"bmp")));

        /*wr.writeInt(pngImage.getWidth());
        wr.writeInt(pngImage.getHeight());*/

        for (int y = 0; y < pngImage.getHeight(); y++) {
            for (int x = 0; x < pngImage.getWidth(); x++) {
                int pixel = pngImage.getRGB(x, y);

                int a = ((~pixel) & 0xFF000000) >>> 24;
                int r = (pixel & 0x00FF0000) >>> 16;
                int g = (pixel & 0x0000FF00) >>> 8;
                int b = pixel & 0x000000FF;
                
                System.out.println("Alpha: " + a + " Red: " + r + " Green: " + g + " Blue: " + b);
    
                wr.writeByte(a);
                wr.writeByte(b);
                wr.writeByte(g);
                wr.writeByte(r);
            }
        }

        wr.close();
    }
}
