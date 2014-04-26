require 'gosu'

module ECS
 
  MILLISECOND = 0.001

  def self.make_sprite image, anchor={:x => 0.5, :y => 0.5}
    {:image => image, :anchor => anchor}
  end

  class Engine

    def initialize
      @last_time = Gosu::milliseconds
      @time = 0

      @systems = {:update => {}, :draw => {}, :up => {}, :down => {}}
      @entities = []
      @input_state = {}
    end

    def system type, name, &block
      @systems[type][name] = block
      self
    end

    def remove_system type, name
      @systems[type].delete name
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
      @systems[:down].each_value do |s|
        s.call id
      end
    end

    def button_up id
      @systems[:up].each_value do |s|
        s.call id
      end
    end

    def update
      new_time = Gosu::milliseconds
      dt = (new_time-@last_time).to_f*MILLISECOND
      @time += dt
      @last_time = new_time

      @systems[:update].each_value do |s|
        s.call dt, @time
      end
      @entities.delete_if { |e| e[:delete] }

      @input_state.clear
    end

    def draw
      @systems[:draw].each_value do |s|
        s.call
      end
    end

  end

end