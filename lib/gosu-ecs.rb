require 'gosu'

module ECS
 
  MILLISECOND = 0.001

  def self.make_sprite image, anchor={:x => 0.5, :y => 0.5}
    {:image => image, :anchor => anchor}
  end

  class Window < Gosu::Window

    def initialize width, height, fullscreen, update_interval = 16.666666
      super

      @last_time = Gosu::milliseconds
      @time = 0

      @systems = {}
      @up_systems = {}
      @down_systems = {}
      @entities = []
      @input_state = {}
    end

    def system name, &block
      @systems[name] = block
      self
    end

    def up_system name, &block
      @up_systems[name] = block
      self
    end

    def down_system name, &block
      @down_systems[name] = block
      self
    end

    def remove_system name
      @systems.delete name
    end

    def add_node node, components
      @nodes[node] = component
      @node_lists[node] = []
      self
    end

    def add_entity entity
      @entities << entity
    end

    def remove_entity entity
      entity[:delete] = true
    end

    def each_entity node
      @entities.each do |e|
        matches = true
        node.each do |c|
          unless e.include? c
            matches = false
            break
          end
        end
        yield e if matches
      end
    end

    def button_down id
      @down_systems.each_value do |s|
        s.call id
      end
    end

    def button_up id
      @up_systems.each_value do |s|
        s.call id
      end
    end

    def update
      new_time = Gosu::milliseconds
      dt = (new_time-@last_time).to_f*MILLISECOND
      @time += dt
      @last_time = new_time

      @systems.each_value do |s|
        s.call dt, @time
      end
      @entities.delete_if { |e| e[:delete] }

      @input_state.clear
    end

    def draw
      each_entity [:position, :sprite] do |e|
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]*img.width
        dy = e[:sprite][:anchor][:y]*img.height
        img.draw x-dx, y-dy, 0
      end
    end

  end

end