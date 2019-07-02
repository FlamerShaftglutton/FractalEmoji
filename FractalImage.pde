PImage output;
int image_size = 32;
float cutoff = 10f;


void setup()
{
  size(1200,1200);
  
  //selectInput("Select a PNG", "fileselected");
  
  fileselected();
}

void draw()
{

    image(output,0f,0f);
    saveFrame("ouptut.png");

}

//void fileselected(File selected)
void fileselected()
{
  /*
  if (selected == null)
    return;
  
  PImage base = loadImage(selected.getAbsolutePath());
  base.resize(image_size,image_size);
  */
  
  PImage base = loadImage("C:\\Users\\boi\\Processing\\Projects\\FractalImage\\base.png");
  PImage dark = loadImage("C:\\Users\\boi\\Processing\\Projects\\FractalImage\\dark.png");
  PImage light = loadImage("C:\\Users\\boi\\Processing\\Projects\\FractalImage\\light.png");
  
  base.resize(image_size,image_size);
  dark.resize(image_size, image_size);
  light.resize(image_size, image_size);
  
  PImage[] bucket_images = {dark,dark,dark,dark,base,base,base,light};

  //now that we have our image, determine how many "pixels" our blown-up image will have
  int pix = min(height/image_size, width/image_size);
  
  //now create a copy of the image and shrink it to that many pixels
  PImage ref = base.copy();
  ref.resize(pix,pix);
  
  //create a fresh canvas to draw on
  output = createImage(pix * image_size, pix * image_size, ARGB);
  
  //DEBUG
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
        int bucket = bucketize_brightness(r, min_val, max_val);
        
        output.copy(bucket_images[bucket], 0,0,image_size,image_size,x * image_size, y * image_size, image_size, image_size);
        
        //if (bucket > baseline_index)
        //  output.copy(light,0,0,image_size,image_size,x * image_size, y * image_size, image_size, image_size);
        //else if (bucket < baseline_index)
        //  output.copy(dark,0,0,image_size,image_size,x * image_size, y * image_size, image_size, image_size);
        //else
        //  output.copy(base,0,0,image_size,image_size,x * image_size, y * image_size, image_size, image_size);
        
        //output.copy(base,0,0,image_size,image_size,x * image_size, y * image_size, image_size, image_size);
        //output.copy(ref,x,y,1,1,x*image_size,y*image_size,image_size,image_size);
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
