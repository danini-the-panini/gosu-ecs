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
      @chunks = {
        :default => gen_chunk
      }
      @chunks_to_add = {}
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

    def activate_chunk name, value=true
      chunk = create_chunk(name)
      chunk[:active] = value
    end

    def create_chunk name
      chunk = @chunks[name] || @chunks_to_add[name]
      if chunk.nil?
        chunk = gen_chunk
        (@updating ? @chunks_to_add : @chunks)[name] = (chunk)
      end
      chunk
    end

    def add_entity entity, chunk_name = :default
      chunk = create_chunk(chunk_name)
      chunk[@updating ? :entities_t1 : :entities][@entity_num] = entity
      entity[:id] = @entity_num
      @entity_num += 1
      self
    end

    def inject_state state
      state.each do |k,c|
        c[:entities].each do |i,e|
          add_entity e, k
        end
      end
    end

    def remove_entity entity
      entity[:delete] = true
      self
    end

    def each_entity n
      @chunks.each_value do |c|
        if c[:active]
          c[:entities].each do |i, e|
            if matches? e, n
              yield e
            end
          end
        end
      end
    end

    def entities
      @chunks.values.reduce({}) do |entities,c|
        if c[:active]
          entities.merge(c[:entities])
        else
          entities
        end
      end
    end

    def chunks
      @chunks
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
      @chunks.each_value do |c|
        if c[:active]
          c[:entities].each do |i, e|
            each_with_entity_input @input_systems[:down], i, e, id
          end
        end
      end
      @input_state[id] = true
    end

    def button_up id
      @chunks.each_value do |c|
        if c[:active]
          c[:entities].each do |i, e|
            each_with_entity_input @input_systems[:up], i, e, id
          end
        end
      end
      @input_state[id] = false
    end

    def update
      @updating = true
      new_time = Gosu::milliseconds
      dt = (new_time-@last_time).to_f*MILLISECOND
      @time += dt
      @last_time = new_time

      @chunks.each_value do |c|
        c[:entities].delete_if do |i, e|
          c[:entities_t1][i] = e unless c[:entities_t1].include?(i)
          each_with_entity_new @systems[:update], i, e, dt, c

          e = c[:entities_t1][i]
          e.delete_if { |k,v| v.nil? }
          c[:entities_t1].delete i if e[:delete]
          e[:delete]
        end

        # swap entity buffers
        temp = c[:entities]
        c[:entities] = c[:entities_t1]
        c[:entities_t1] = temp
      end

      @chunks.merge! @chunks_to_add
      @chunks_to_add.clear

      @updating = false
    end

    def draw
      @chunks.each_value do |c|
        if c[:active]
          c[:entities].each do |i, e|
            each_with_entity @systems[:draw], i, e
          end
        end
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

      def each_with_entity_new sys, i, e, dt, chunk
        sys.each_value do |n, s|
          if matches?(e, n) && !chunk[:entities_t1][i].nil?
            chunk[:entities_t1][i].merge!(s.call(dt, @time, e))
          end
        end
      end

      def gen_chunk
        {
          :entities => {},
          :entities_t1 => {},
          :active => true
        }
      end

  end

end