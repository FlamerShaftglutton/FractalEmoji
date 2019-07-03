PImage output;
int image_size = 32;
float cutoff = 10f;

ImagePicker base_picker;
ImagePicker[] bucket_pickers;

void setup()
{
  size(1600,1200);
  
  setup_pickers();
  
  create_output();
}

void draw()
{
  background(200);
  
  image(output, width - output.width, 0f);
  
  base_picker.draw();
  
  for (ImagePicker i : bucket_pickers)
    i.draw();
}

void setup_pickers()
{
  base_picker = new ImagePicker(new PVector(16f, 16f), new PVector(image_size,image_size));
  bucket_pickers = new ImagePicker[8];
  for (int i = 0; i < bucket_pickers.length; ++i)
     bucket_pickers[i] = new ImagePicker(new PVector(16f, 80 + i * 48), new PVector(image_size,image_size));
  
  base_picker.set_image(loadImage("base.png"));
  
  for (int i = 0; i < bucket_pickers.length; ++i)
  {
    PGraphics g = createGraphics(image_size, image_size);
    g.beginDraw();
    
    g.stroke(0);
    g.strokeWeight(1);
    g.fill(90 + i * 20);
    g.rect(0,0, image_size, image_size);
    
    g.fill(0);
    g.textSize(3 * image_size / 4);
    g.textAlign(CENTER,CENTER);
    g.text("" + i, image_size / 2, image_size / 2);
    
    g.endDraw();
    
    bucket_pickers[i].set_image(g);
  }
}

//void fileselected(File selected)
void create_output()
{
  //now that we have our image, determine how many "pixels" our blown-up image will have
  int pix = min(height/image_size, width/image_size);
  
  //now create a copy of the image and shrink it to that many pixels
  PImage ref = base_picker.get_image().copy();
  ref.resize(pix,pix);
  
  //create a fresh canvas to draw on
  output = createImage(pix * image_size, pix * image_size, ARGB);
  output.loadPixels();
  for (int i = 0; i < output.pixels.length; ++i)
    output.pixels[i] = color(200);
  output.updatePixels();
  
  //find the min and max brightness scores
  float min_val = Float.MAX_VALUE;
  float max_val = -Float.MAX_VALUE;
  for (int x = 0; x < ref.width; ++x)
  {
    for (int y = 0; y < ref.height; ++y)
    {
      color c = ref.get(x,y);
      if (alpha(c) > cutoff)
      {
        float xx = brightness_score(c);
        
        if (xx < min_val)
          min_val = xx;
        if (xx > max_val)
          max_val = xx;
      }
    }
  } //<>//
  

  //for each pixel in the reference photo add the full pic to the output
  for (int x = 0; x < ref.width; ++x)
  {
    for (int y = 0; y < ref.height; ++y)
    {
      color r = ref.get(x,y);
      
      if (alpha(r) > cutoff)
      {
        //determine which bucket to pull the image from
        int bucket = bucketize_brightness(r, min_val, max_val);
        
        //copy that bucket's image into the output image
        output.copy(bucket_pickers[bucket].get_image(), 0,0,image_size,image_size,x * image_size, y * image_size, image_size, image_size);
      }
    }
  }
}

int bucketize_brightness(color c, float min, float max)
{
  return int(8f * (brightness_score(c) - min) / (max - min + 0.001f));
}

float brightness_score(color c)
{
  return sqrt(red(c) * red(c) * 0.241f + green(c) * green(c) * 0.691f + blue(c) * blue(c) * 0.068f);
}

void keyReleased()
{
  if (key == 's')//save the output if you press the 's' key
    output.save("output.png");
}

void mouseReleased()
{
  PVector m = new PVector(mouseX, mouseY);
  if (!base_picker.handle_mouse_event(m))
    for (int i = 0; i < bucket_pickers.length && !bucket_pickers[i].handle_mouse_event(m); ++i);
  
  //recreate the output image anytime we click
  create_output();
}

public class ImagePicker
{
  private PVector pos;
  private PVector dim;
  
  private PImage my_image;
  
  ImagePicker(PVector pos, PVector dim)
  {
    this.pos = new PVector(pos.x, pos.y);
    this.dim = new PVector(dim.x, dim.y);
    
    my_image = createImage(image_size, image_size, ARGB);
  }
  
  void set_image(PImage new_image)
  {
    if (new_image != null)
    {
      my_image = new_image;
      
      if (my_image.width != image_size || my_image.height != image_size)
        my_image.resize(image_size, image_size);
    }
  }
  
  PImage get_image()
  {
    return my_image;
  }
  
  void draw()
  {
    image(my_image, pos.x, pos.y);
    
    stroke(0);
    strokeWeight(1);
    noFill();
    rect(pos.x, pos.y, dim.x, dim.y);
  }
  
  boolean handle_mouse_event(PVector mouse_pos)
  {
    if (mouse_pos.x < pos.x || mouse_pos.x >= pos.x + dim.x || mouse_pos.y < pos.y || mouse_pos.y >= pos.y + dim.y) //<>//
      return false;
    
    selectInput("Select a PNG", "file_picked",null,this);
    
    return true;
  }
  
  public void file_picked(File f)
  {
    if (f != null)
    {
      set_image(loadImage(f.getAbsolutePath()));
      
      //recreate the big image (since this is called asychronously this can't just be put in the mouseReleased event)
      create_output();
    }
  }
}
