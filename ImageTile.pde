public class ImageTile
{
  private PVector original_pos;
  private PVector pos;
  private PVector dim;
  
  private PImage my_image;
  
  private boolean currently_dragging;
  private PVector dragging_offset;
  
  public ImageTile(PVector pos, PVector dim)
  {
    this.pos = new PVector(pos.x, pos.y);
    this.original_pos = new PVector(pos.x, pos.y);
    this.dim = new PVector(dim.x, dim.y);
    
    my_image = createImage(tile_size, tile_size, ARGB);
    
    currently_dragging = false;
    dragging_offset = new PVector(-1,-1);
  }
  
  public void set_image(PImage new_image)
  {
    if (new_image != null)
    {
      my_image = new_image;
      
      if (my_image.width != tile_size || my_image.height != tile_size)
        my_image.resize(tile_size, tile_size);
    }
  }
  
  public PImage get_image()
  {
    return my_image;
  }
  
  public PVector get_pos()
  {
    return pos.copy();
  }
  
  public void draw()
  {
    if (currently_dragging)
      pos = PVector.add(new PVector(mouseX, mouseY), dragging_offset);
    
    image(my_image, pos.x, pos.y);
    
    stroke(0);
    strokeWeight(1);
    noFill();
    rect(pos.x, pos.y, dim.x, dim.y);
  }
  
  public void mousePressed(PVector mouse_pos)
  {
    if (contains_point(mouse_pos))
    {
      currently_dragging = true;
      dragging_offset = PVector.sub(pos,mouse_pos);
    }
  }
  
  public void mouseReleased(PVector mouse_pos)
  {
    if (currently_dragging)
    {
      currently_dragging = false;
      
      pos = new PVector(original_pos.x, original_pos.y);
      
      if (base_tile.contains_point(mouse_pos))
      {
        base_tile.set_image(my_image);
      }
      else for (ImageTile i : bucket_tiles)
      {
        if (i.contains_point(mouse_pos))
        {
          i.set_image(my_image);
          break;
        }
      }
    }
  }
  
  public boolean contains_point(PVector p)
  {
    return p.x >= pos.x && p.x < pos.x + dim.x && p.y >= pos.y && p.y < pos.y + dim.y;
  }
}
