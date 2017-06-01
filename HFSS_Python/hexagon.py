import math
from PIL import Image, ImageDraw

def hexagon_generator(edge_length, offset):
  """Generator for coordinates in a hexagon."""
  x, y = offset
  for angle in range(0, 360, 60):
    x += math.cos(math.radians(angle)) * edge_length
    y += math.sin(math.radians(angle)) * edge_length
    yield x, y

def main(edge_length,x,y):
  image = Image.new('RGB', (200, 200), 'white')
  draw = ImageDraw.Draw(image)
  hexagon = hexagon_generator(edge_length, offset=(x, y))
  draw.polygon(list(hexagon), outline='black', fill='red')
  image.show()

# edge_length = 20
# xoffset = 5
# yoffset = 5
# for i in range(1,3):
#     for n in range(1, 3):
#         y = yoffset + n * edge_length
#         print("y=",y)
#         x = xoffset + i * edge_length
#         print("x=",x)
#         image = Image.new('RGB', (200, 200), 'white')
#         draw = ImageDraw.Draw(image)
#         hexagon = hexagon_generator(edge_length, offset=(x, y))
#         draw.polygon(list(hexagon), outline='black', fill='red')
#         image.show()


hexagon_generator(20, offset = (5,5))
