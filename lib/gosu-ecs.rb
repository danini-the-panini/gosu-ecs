require 'gosu'

module ECS
 
  MILLISECOND = 0.001

  class Engine

    def initialize
      @last_time = Gosu::milliseconds
      @time = 0

      @entity_num = 0
      @systems = {:update => {}, :draw => {}}
      @input_systems = {:up => {}, :down => {}}
      @entities = {}
      @entities_t1 = {}
      @input_state = {}
    end

    def system type, name, node, &block
      @systems[type][name] = [node, block]
      self
    end

    def remove_system type, name
      @systems[type].delete name
      self
    end

    def input_system type, name, node, &block
      @input_systems[type][name] = [node, block]
      self
    end

    def remove_input_system type, name
      @input_systems[type].delete name
      self
    end

    def add_entity entity
      (@updating ? @entities_t1 : @entities)[@entity_num] = entity
      @entity_num += 1
      self
    end

    def remove_entity entity
      entity[:delete] = true
      self
    end

    def each_entity n
      @entities.each do |i, e|
        if matches? e, n
          yield e
        end
      end
    end

    def down? id
      @input_state[id]
    end

    def pause
      @input_state.clear
    end

    def unpause
      @input_state.clear
      @last_time = Gosu::milliseconds
    end

    def button_down id
      @entities.each do |i, e|
        each_with_entity_input @input_systems[:down], i, e, id
      end
      @input_state[id] = true
    end

    def button_up id
      @entities.each do |i, e|
        each_with_entity_input @input_systems[:up], i, e, id
      end
      @input_state[id] = false
    end

    def update
      @updating = true
      new_time = Gosu::milliseconds
      dt = (new_time-@last_time).to_f*MILLISECOND
      @time += dt
      @last_time = new_time

      @entities.delete_if do |i, e|
        @entities_t1[i] = e unless @entities_t1.include?(i)
        each_with_entity_new @systems[:update], i, e, dt

        e = @entities_t1[i]
        @entities_t1.delete i if e[:delete]
        e[:delete]
      end

      # swap entity buffers
      temp = @entities
      @entities = @entities_t1
      @entities_t1 = temp

      @updating = false
    end

    def draw
      @entities.each do |i, e|
        each_with_entity @systems[:draw], i, e
      end
    end

    private

      def matches? entity, node
        node.each do |c|
          return false if !entity.include?(c)
        end
        true
      end

      def each_with_entity sys, i, e
        sys.each_value do |n, s|
          if matches? e, n
            s.call e
          end
        end
      end

      def each_with_entity_input sys, i, e, id
        sys.each_value do |n, s|
          if matches? e, n
            s.call id, e
          end
        end
      end

      def each_with_entity_new sys, i, e, dt
        sys.each_value do |n, s|
          if matches?(e, n) && !@entities_t1[i].nil?
            @entities_t1[i].merge!(s.call(dt, @time, e))
          end
        end
      end

  end

end