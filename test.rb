require_relative 'lib/gosu-ecs'

class FooWindow < ECS::Window

  def initialize width = 800, height = 600, fullscreen = false
    super

    system :foo_move do |dt, time|
      each_entity [:position] do |e|
        e[:position][:x] = 400+Math::cos(time)*100
        e[:position][:y] = 300+Math::sin(time)*100
      end
    end

    foo_image = Gosu::Image.from_text self, "FOO!", Gosu::default_font_name, 30

    @foo = {
      :sprite => ECS::make_sprite(foo_image),
      :position => {:x => 0, :y => 0}
    }

    add_entity @foo
  end

end

FooWindow.new.show