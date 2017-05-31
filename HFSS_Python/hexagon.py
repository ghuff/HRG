import math
from PIL import Image, ImageDraw

def hexagon_generator(edge_length, offset):
  """Generator for coordinates in a hexagon."""
  x, y = offset
  for angle in range(0, 360, 60):
    x += math.cos(math.radians(angle)) * edge_length
    y += math.sin(math.radians(angle)) * edge_length
    yield x, y

def main():
  image = Image.new('RGB', (100, 100), 'white')
  draw = ImageDraw.Draw(image)
  hexagon = hexagon_generator(40, offset=(30, 15))
  draw.polygon(list(hexagon), outline='black', fill='red')
  image.show()

main()