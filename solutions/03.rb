module Graphics
  class Renderers
    class Ascii
      def initialize(canvas)
        @canvas = canvas
      end

      def render
        output = ""
        @canvas.pixels.each_index do |index|
          output << (@canvas.pixels[index] ? "@" : "-")
          output << "\n" if  ((index + 1).remainder (@canvas.width)) == 0
        end
        output.chomp
      end
    end

    class Html
      def initialize(canvas)
        @canvas = canvas
        @html_code = ['
          <!DOCTYPE html>
          <html>
          <head>
            <title>Rendered Canvas</title>
            <style type="text/css">
              .canvas {
                font-size: 1px;
                line-height: 1px;
              }
              .canvas * {
                display: inline-block;
                width: 10px;
                height: 10px;
                border-radius: 5px;
              }
              .canvas i {
                background-color: #eee;
              }
              .canvas b {
                background-color: #333;
              }
            </style>
          </head>
          <body>
            <div class="canvas">',
          '
            </div>
          </body>
        </html>']
      end

      def render
        output = @html_code[0]
        @canvas.pixels.each_index do |index|
          output << (@canvas.pixels[index] ? "<b></b>" : "<i></i>")
          output << "<br>\n" if ((index + 1).remainder (@canvas.width)) == 0
        end
        output.chomp.chop.chop.chop.chop << @html_code[1]
      end
    end
  end

  class Canvas
    attr_reader :width, :height, :pixels

    def initialize(width, height)
      @width  = width
      @height = height
      @pixels = []
      (width * height).times { @pixels << false }
    end

    def set_pixel(x, y)
      @pixels[x + width * y] = true
    end

    def pixel_at?(x, y)
      @pixels[x + width * y]
    end

    def draw(shape)
      shape.points.each do |point|
        set_pixel point.x, point.y
      end
    end

    def render_as(renderer)
      renderer.new(self).render
    end
  end

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def points
      [Point.new(x, y)]
    end

    def ==(other_point)
      x == other_point.x and y == other_point.y
    end

    def eql?(other_point)
      self == other_point
    end

    def hash
      x.hash % y.hash
    end
  end

  class Line
    def initialize(from, to)
      @from = from
      @to = to
    end

    def from
      Point.new @from.x <= @to.x ? @from.x : @to.x,
                @from.x <= @to.x ? @from.y : @to.y
    end

    def to
      Point.new @from.x > @to.x ? @from.x : @to.x,
                @from.x > @to.x ? @from.y : @to.y
    end

    def points(left = from, right = to, result = [left, right])
      return result if (left.x - right.x).abs <= 1 and (left.y - right.y).abs <= 1
      result << Point.new((left.x + right.x) / 2, (left.y + right.y) / 2)
      points left, Point.new((left.x + right.x) / 2, (left.y + right.y) / 2), result
      points Point.new((left.x + right.x) / 2, (left.y + right.y) / 2), right, result
    end

    def ==(other_line)
      from == other_line.from and to == other_line.to
    end

    def eql?(other_line)
      self == other_line
    end

    def hash
      from.hash + to.hash
    end
  end

  class Rectangle
    def initialize(top_left, bottom_right)
      @top_left = top_left
      @bottom_right = bottom_right
    end

    def top_left
      left
    end

    def bottom_right
      right
    end

    def top_right
      Point.new bottom_right.x, top_left.y
    end

    def bottom_left
      Point.new top_left.x, bottom_right.y
    end

    def left
      Point.new @top_left.x < @bottom_right.x ? @top_left.x : @bottom_right.x,
                @top_left.y < @bottom_right.y ? @top_left.y : @bottom_right.y
    end

    def right
      Point.new @top_left.x > @bottom_right.x ? @top_left.x : @bottom_right.x,
                @top_left.y > @bottom_right.y ? @top_left.y : @bottom_right.y
    end

    def points
      [(Line.new top_left, top_right).points,
       (Line.new top_left, bottom_left).points,
       (Line.new top_right, bottom_right).points,
       (Line.new bottom_left, bottom_right).points].flatten
    end

    def ==(rectangle)
      top_left == rectangle.top_left and bottom_right == rectangle.bottom_right
    end

    def eql?(rectangle)
      self == rectangle
    end

    def hash
      top_left.hash + top_right.hash + bottom_right.hash + bottom_left.hash
    end
  end
end