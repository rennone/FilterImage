import java.lang.StringBuffer;
import java.io.FileWriter;
import java.io.*;
import java.awt.datatransfer.DataFlavor;  
import java.awt.datatransfer.Transferable;  
import java.awt.datatransfer.UnsupportedFlavorException;  
import java.awt.dnd.DnDConstants;  
import java.awt.dnd.DropTarget;  
import java.awt.dnd.DropTargetDragEvent;  
import java.awt.dnd.DropTargetDropEvent;  
import java.awt.dnd.DropTargetEvent;  
import java.awt.dnd.DropTargetListener;  
import java.io.File;  
import java.io.IOException;  
import java.util.List;

DropTarget dropTarget;
final String Indication = "Drop folder";
final String Condition  = "Now Calculating";

int progressBar = -1;

// calculate Saturation by RGB
float getSaturation(color c)
{
  float maxC = max(red(c), max(green(c), blue(c)) );
  float minC = min(red(c), min(green(c), blue(c)) );
  return (maxC - minC);
}


float getRateOfColor(PImage img)
{  
  img.loadPixels();
  float epsilon = 1.0f; //
 int cnt = 0; 
  for(int y=0; y<img.height; y++)
  {
    for(int x=0; x<img.width; x++)
    {
      int pos = x + y*img.width;
      float sat = getSaturation(img.pixels[pos]);
      if( sat <= epsilon)
      cnt++;
    }
  }  
  return 1.0f - 1.0f * cnt / img.height / img.width; 
}
  
int getFilterImg(PImage img, PImage rImg)
{
  img.loadPixels();
// copy Img to left of rImg;
   for(int y=0; y<img.height; y++){
    for(int x=0; x<img.width; x++){
      int pos1 = x + y*img.width;
      int pos2 = x + y*rImg.width;
      rImg.pixels[pos2] = img.pixels[pos1];
    }
  }
  
  float acceptableError = 5.0f; // 
  int cnt = 0;
  for(int y=0; y<img.height; y++)
  {
    for(int x=0; x<img.width; x++)
    {
      int pos  = x + y*img.width;
      int pos2 = img.width+x + y*rImg.width;
      int s = (int)getSaturation(img.pixels[pos]);
      if( s <= acceptableError )
      {
        rImg.pixels[pos2] = color(0);
      }
      else
      {
        rImg.pixels[pos2] = color(255);
        cnt++;
      }      
    }
  }
  return cnt; 
}

// check fileName is png or jpeg or jpg or bmp;
boolean isImage(String fileName)
{
   String[] m = match(fileName, ".(png|jpeg|bmp|jpg)" );
   return m != null;
}

void draw_progress(int percent)
{
  background(0);
  text("Now Calculating", width/2, height/2);
  text(percent+"%", width*3/4, height*3/4);
}

void makeFilteredImage(String folder)
{
  File directory1 = new File(folder);
  File[] fileArray = directory1.listFiles();
  ArrayList<PImage> images = new ArrayList<PImage>();
  if (fileArray != null) {
    for(int i = 0; i < fileArray.length; i++) 
    {    
     if( !isImage(fileArray[i].getName()) ) continue;
     
       images.add(loadImage(fileArray[i].getAbsolutePath()));
    }
  } else{
    System.out.println(directory1.toString() + " not found" );
    exit();    
  }
  
  String folderPath = folder + "/images/";
  int num = images.size();
  PrintWriter output = createWriter(folderPath + "rateOfCromaticColor.txt");
  for(int i=0; i<num; i++)
  {
    PImage img = images.get(i);
    PImage rImg = createImage(img.width*2, img.height, RGB);
    int cnt = getFilterImg(img, rImg);
    output.println(1.0f*cnt/img.width/img.height);
    rImg.save(folderPath + nf(i,4) + ".png");
    draw_progress(100*i/num);
  }
  output.flush();
  output.close();
}


void setup()
{
  dropTarget = new DropTarget(this, new DropTargetListener() 
  {
    public void dragEnter(DropTargetDragEvent e){}
    public void dragOver(DropTargetDragEvent e){}
    public void dropActionChanged(DropTargetDragEvent e) {}
    public void dragExit(DropTargetEvent e) {}  
    public void drop(DropTargetDropEvent e) {
      e.acceptDrop(DnDConstants.ACTION_COPY_OR_MOVE);
      Transferable trans = e.getTransferable();
      List<File> fileNameList = null;
      if(trans.isDataFlavorSupported(DataFlavor.javaFileListFlavor)){
        try{
          fileNameList = (List<File>)trans.getTransferData(DataFlavor.javaFileListFlavor);
        }catch(UnsupportedFlavorException ex){
          //
        } catch(IOException ex){
          //
        }
      }
      if(fileNameList == null)     return;
      
      background(0);
      text("Now Calculating", width/2, height/2);
      for(File f : fileNameList)
      {
        println(f.getName());
        if( f.isDirectory() )
        {
          makeFilteredImage(f.getAbsolutePath());
        }
      }
      
      background(0);
      text("drop folder", width/2, height/2);
    }  
  });
  
  size(400, 400);
  textAlign(CENTER);
  textSize(32);
  background(0);
  text("drop folder", width/2, height/2);
  //noLoop();
}

void draw()
{
}

