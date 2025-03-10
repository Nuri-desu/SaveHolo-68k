package scripts;

import java.awt.image.BufferedImage;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;

import javax.imageio.ImageIO;

public class PngTo68KCollision {
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
            write68kCollision(pngImage,pngImageName);
        } catch (Exception e) {
            System.err.println("no");
        }
    }

    private static void write68kCollision(BufferedImage pngImage, String pngImageName) throws Exception{
        char [] pngImageNameCharArr = pngImageName.toCharArray();

        pngImageNameCharArr[pngImageNameCharArr.length -3] = '6';
        pngImageNameCharArr[pngImageNameCharArr.length -2] = '8';
        pngImageNameCharArr[pngImageNameCharArr.length -1] = 'k';

        String mot68kImageName = String.valueOf(pngImageNameCharArr);

        DataOutputStream wr = new DataOutputStream(new FileOutputStream(new File("68k images/"+mot68kImageName+"col")));

        /*wr.writeInt(pngImage.getWidth());
        wr.writeInt(pngImage.getHeight());*/

        final int THRESHOLD = 0xFF/3;
        for (int y = 0; y < pngImage.getHeight(); y++) {
            for (int x = 0; x < pngImage.getWidth(); x++) {
                int pixel = pngImage.getRGB(x, y);

                byte toWrite = 0;

                int a = ((~pixel) & 0xFF000000) >>> 24;
                int r = (pixel & 0x00FF0000) >>> 16;
                int g = (pixel & 0x0000FF00) >>> 8;
                int b = pixel & 0x000000FF;
                
                if(a >= 0xFF - THRESHOLD)                   toWrite = (byte) (toWrite | 0b10000000);    //previous stage
                if(a <= 0xFF - THRESHOLD && a >= THRESHOLD) toWrite = (byte) (toWrite | 0b01000000);    //next stage
                if(r >= 0xFF - THRESHOLD)                   toWrite = (byte) (toWrite | 0b00100000);    //ground
                if(r <= 0xFF - THRESHOLD && r >= THRESHOLD) toWrite = (byte) (toWrite | 0b00010000);    //cealing
                if(g >= 0xFF - THRESHOLD)                   toWrite = (byte) (toWrite | 0b00001000);    //right wall
                if(g <= 0xFF - THRESHOLD && g >= THRESHOLD) toWrite = (byte) (toWrite | 0b00000100);    //left wall
                if(b >= 3*0xFF/4)                           toWrite = (byte) (toWrite | 0b00000011);    // where to stage down
                if(b < 3*0xFF/4 && b >= 2*0xFF/4)           toWrite = (byte) (toWrite | 0b00000010);    // where to stage right
                if(b < 2*0xFF/4 && b >= 0xFF/4)             toWrite = (byte) (toWrite | 0b00000001);    // where to stage up
                //si b = 0                                  toWrite = 0                                 // where to stage left
                                                                                                        // prev stage | next stage | is on ground | is touching cealing | is touching right wall | is touching left wall | where stage index | where stage index
                                                                                                        // where stage: 0 = left, 1 = up, 2 = right, 3 = down
                //0b00000000 it's air

                wr.writeByte(toWrite);
            }
        }

        wr.close();
    }
}
