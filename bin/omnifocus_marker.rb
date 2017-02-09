require 'omnifocus'
require 'active_support/all'

class OmniFocusMarker

  @instance = OmniFocus.new

  class << self

    def omnifocus
      @instance
    end

    def get_tasks_and_projects
      @tasks_and_projects ||=  @instance.all_tasks + @instance.all_projects.map(&:thing)
    end

    def get_context(name)
      @instance.all_contexts.select{|x| x.name == name}.first
    end

    def get_project(name)
      @instance.all_projects.select{|x| x.name == name}.first
    end

    def get_task(name)
      @instance.all_tasks.select{|x| x.name.get == name}.first
    end

    def set_context(target, context)
      target = target.thing unless target.is_a? AS_SafeObject
      context = context.thing unless context.is_a? AS_SafeObject
      puts "-- Change Context: '#{target.name.get}',  from '#{target.context.get == :missing_value ? 'None' : target.context.name.get}' to '#{context.name.get}'"
      target.context.set context
    end

    def mark_flagged
      puts "processing context Flag"
      items = get_tasks_and_projects.select{|x| time_between(x.due_date.get, Time.now.beginning_of_day, Time.now.end_of_day) && !x.completed.get && !x.flagged.get}
      items.each do |item|
        item.flagged.set true
        puts "-- Mark Flagged: '#{item.name.get}'"
      end
    end

    def mark_doing_items
      puts "processing context Doing"
      items = get_tasks_and_projects.select{|x| time_before(x.defer_date.get, Time.now) && !x.completed.get}
      items.each do |item|
        new_context = nil
        if item.context.get == :missing_value
          new_context = get_context("Team Doing")
        else
          context_name = item.context.name.get
          if (m = context_name.match(/(.+)\s+(todo|backlog|done)$/i))
            new_context = get_context(m[1] + " Doing")
          end
        end
        set_context item, new_context if new_context
      end
    end

    def mark_todo_items
      puts "processing context Todo"
      items = get_tasks_and_projects.select{|x| time_after(x.defer_date.get, Time.now) && !x.completed.get}
      items.each do |item|
        new_context = nil
        if item.context.get == :missing_value
          new_context = get_context("Team Todo")
        else
          context_name = item.context.name.get
          if (m = context_name.match(/(.+)\s+(doing|backlog|done)$/i))
            new_context = get_context(m[1] + " Todo")
          end
        end
        set_context item, new_context if new_context
      end
    end

    def mark_backlog_items
      puts "processing context Backlog"
      items = get_tasks_and_projects.select{|x| x.defer_date.get == :missing_value && !x.completed.get}
      items.each do |item|
        new_context = nil
        if item.context.get == :missing_value
          new_context = get_context("Team Backlog")
        else
          context_name = item.context.name.get
          if (m = context_name.match(/(.+)\s+(doing|todo|done)$/i))
            new_context = get_context(m[1] + " Backlog")
          end
        end
        set_context item, new_context if new_context
      end
    end

    def mark_done_items
      puts "processing context Done"
      items = get_tasks_and_projects.select{|x| x.completed.get}
      items.each do |item|
        new_context = nil
        if item.context.get == :missing_value
          new_context = get_context("Team Done")
        else
          context_name = item.context.name.get
          if (m = context_name.match(/(.+)\s+(doing|backlog|todo)$/i))
            new_context = get_context(m[1] + " Done")
          end
        end
        set_context item, new_context if new_context
      end
    end

    def time_between(time, start_time, end_time)
      time = nil if time == :missing_value
      time && time >= start_time && time <= end_time
    end

    def time_before(time, compare)
      time = nil if time == :missing_value
      time && time <= compare
    end

    def time_after(time, compare)
      time = nil if time == :missing_value
      time && time >= compare
    end


  end

end

if __FILE__ == $0
  puts "Start processing"
  OFM = OmniFocusMarker
  OFM.mark_doing_items
  OFM.mark_todo_items
  OFM.mark_backlog_items
  OFM.mark_done_items
  OFM.mark_flagged
  puts "Finish processing"
end
