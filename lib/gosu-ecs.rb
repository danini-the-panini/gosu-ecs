require 'gosu'

module ECS
 
  MILLISECOND = 0.001

  class Window < Gosu::Window

    def initialize width, height, fullscreen, update_interval = 16.666666
      super

      @last_update = milliseconds
      @last_draw = milliseconds
      @time = 0

      @systems = {}
    end

    def update
      @last_update = time_period do |dt|
        @time += dt
        systems.each_value do |s|
          s.call self, dt
        end
      end
    end

    def draw
      @last_draw = time_period do |dt|
        draw_system.call self, dt
      end
    end

    private

      def time_period
        new_time = milliseconds
        dt = (new_time-milliseconds).to_f*MILLISECOND
        
        yield dt

        new_time
      end

  end

end