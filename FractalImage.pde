PImage output;
int tile_size = 32;
float cutoff = 10f;

ImageTile base_tile;
ImageTile[] bucket_tiles;
ArrayList<ImageTile> palette_tiles;

void setup()
{
  size(1600,1200);
  
  init();
  
  create_output();
}

void draw()
{
  background(200);
  
  image(output, width - output.width, 0f);
  
  base_tile.draw();
  
  for (ImageTile i : bucket_tiles)
    i.draw();
  
  for (ImageTile i : palette_tiles)
    i.draw();
}

void init()
{
  //intialize the palette tiles
  palette_tiles = new ArrayList<ImageTile>();
  
  //now load up all the images in the data folder
  File dir = new File(dataPath(""));
  float max_palette_x = 80f;
  
  for (File f : dir.listFiles())
  {
    if (f.getAbsolutePath().toLowerCase().endsWith(".png"))
    {
      PImage p = loadImage(f.getAbsolutePath());
      
      if (p != null)
      {
        int starting_y_pos_for_palettes = 80;
        int onepointfive_tile_size = 3 * tile_size / 2;
        
        //figure out how many can fit in a column
        int num_per_column = (height - starting_y_pos_for_palettes) / onepointfive_tile_size;
        
        //determine the position
        PVector np = new PVector(16 + onepointfive_tile_size * (palette_tiles.size() / num_per_column), starting_y_pos_for_palettes + (palette_tiles.size() % num_per_column) * onepointfive_tile_size);

        //create the entry in the palette tiles
        ImageTile it = new ImageTile(np, new PVector(tile_size, tile_size));
        it.set_image(p);
        
        palette_tiles.add(it);
      
        max_palette_x = np.x;
      }
    }
  }
  
  
  //initialize the base_tile
  base_tile = new ImageTile(new PVector(16f, 16f), new PVector(tile_size,tile_size));
  base_tile.set_image(loadImage("data/base.png"));
  
  
  //initialize the bucket_tiles
  bucket_tiles = new ImageTile[8];
  for (int i = 0; i < bucket_tiles.length; ++i)
     bucket_tiles[i] = new ImageTile(new PVector(2 * tile_size + max_palette_x, 80 + i * 48), new PVector(tile_size,tile_size));
  
  //now create the default bucket_tiles from scratch
  for (int i = 0; i < bucket_tiles.length; ++i)
  {
    //create a tile from scratch
    PGraphics g = createGraphics(tile_size, tile_size);
    g.beginDraw();
    
    //border with gradually brighter background
    g.stroke(0);
    g.strokeWeight(1);
    g.fill(90 + i * 20);
    g.rect(0,0, tile_size, tile_size);
    
    //text with the number
    g.fill(0);
    g.textSize(3 * tile_size / 4);
    g.textAlign(CENTER,CENTER);
    g.text("" + i, tile_size / 2, tile_size / 2);
    
    g.endDraw();
    
    //put the from-scratch image into the bucket as a default. Users will replace it later with their own.
    bucket_tiles[i].set_image(g);
  }
}

//void fileselected(File selected)
void create_output()
{
  //now that we have our image, determine how many "pixels" our blown-up image will have
  int pix = min(height/tile_size, width/tile_size);
  
  //now create a copy of the image and shrink it to that many pixels
  PImage ref = base_tile.get_image().copy();
  ref.resize(pix,pix);
  
  //create a fresh canvas to draw on
  PGraphics og = createGraphics(pix * tile_size, pix * tile_size);
  og.beginDraw();
  og.background(200);
  
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
        og.image(bucket_tiles[bucket].get_image(), x * tile_size, y * tile_size);
      }
    }
  }
  
  og.endDraw();
  
  output = og;
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

void mousePressed()
{
  PVector m = new PVector(mouseX, mouseY);
  
  base_tile.mousePressed(m);
  
  for (ImageTile i : bucket_tiles)
    i.mousePressed(m);
  
  for (ImageTile i : palette_tiles)
    i.mousePressed(m);
}

void mouseReleased()
{
  PVector m = new PVector(mouseX, mouseY);
  
  base_tile.mouseReleased(m);
  
  for (ImageTile i : bucket_tiles)
    i.mouseReleased(m);
  
  for (ImageTile i : palette_tiles)
    i.mouseReleased(m);
  
  //recreate the output image anytime we release the mouse button
  create_output();
} //<>//
