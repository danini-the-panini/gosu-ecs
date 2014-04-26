require_relative 'lib/gosu-ecs'

class FooWindow < ECS::Window

  def initialize width = 800, height = 600, fullscreen = false
    super

    system :down, :foo_down do |id|
      if id == Gosu::KbSpace
        puts "Spaaaaace!"
      end
    end

    system :update, :foo_move do |dt, time|
      each_entity [:position, :foo] do |e|
        e[:position][:x] = 400+Math::cos(time)*100
        e[:position][:y] = 300+Math::sin(time)*100
      end
    end

    system :draw, :sprite_draw do
      each_entity [:position, :sprite] do |e|
        x = e[:position][:x]
        y = e[:position][:y]
        img = e[:sprite][:image]
        dx = e[:sprite][:anchor][:x]*img.width
        dy = e[:sprite][:anchor][:y]*img.height
        img.draw x-dx, y-dy, 0
      end
    end

    foo_image = Gosu::Image.from_text self, "FOO!", Gosu::default_font_name, 30
    baz_image = Gosu::Image.from_text self, "BAZ!", Gosu::default_font_name, 30

    add_entity({
      :sprite => ECS::make_sprite(foo_image),
      :position => {:x => 0, :y => 0},
      :foo => true
    })

    add_entity({
      :sprite => ECS::make_sprite(baz_image),
      :position => {:x => 100, :y => 100}
    })
  end

end

FooWindow.new.show