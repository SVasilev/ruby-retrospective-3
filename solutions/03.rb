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
      @pixels[x + width * y] = true if x < width and y < height
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

    def +(other_point)
      Point.new x + other_point.x, y + other_point.y
    end

    def -(other_point)
      Point.new x - other_point.x, y - other_point.y
    end

    def /(divisor)
      Point.new x / divisor, y / divisor
    end
  end

  class Line
    def initialize(from, to)
      from, to = to, from if from.y > to.y
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

    def set_variables_for_bresenham_algorithm
      result = from == to ? [Point.new(from.x, from.y)] : []
      step_count = [(to.x - from.x).abs, (to.y - from.y).abs].max
      { :step_count => step_count, :to_draw => from,
        :delta => (to - from) / step_count.to_r, :result => result }
    end

    def bresenham
      hash = set_variables_for_bresenham_algorithm

      hash[:step_count].succ.times do
        hash[:result] << Point.new(hash[:to_draw].x.round, hash[:to_draw].y.round)
        hash[:to_draw] += hash[:delta]
      end
      hash[:result]
    end

    def points
      return [Point.new(from.x, from.y)] if from == to
      bresenham
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
    attr_reader :top_left, :top_right, :bottom_left, :bottom_right, :left, :right

    def initialize(from, to)
      from, to = to, from if from.x > to.x

      @left = from
      @right = to
      determine_corners
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

    private

    def determine_corners
      y_coordinates = [left.y, right.y]

      @top_left     = Point.new left.x,  y_coordinates.min
      @top_right    = Point.new right.x, y_coordinates.min
      @bottom_left  = Point.new left.x,  y_coordinates.max
      @bottom_right = Point.new right.x, y_coordinates.max
    end
  end
end