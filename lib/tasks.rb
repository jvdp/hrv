class Tasks
  attr_reader :projects

  def initialize(subdomain, username, password)
    @harvest = Harvest.client(subdomain, username, password)
    @projects = @harvest.daily.today.projects
  end

  def find(handle)
    fix = -> n { n.split.join.downcase.gsub(/\[[^\]]*\]|\W/, "") }
    @projects.find do |project|
      fix[project.client + project.name].include? fix[handle]
    end
  end

  def dump(handle, date, hours, notes)
    project = find(handle) || @projects.first
    task = project.tasks.first
    puts [
      date.strftime("%d-%m-%Y"),
      project.client.to_s.ljust(@projects.map(&:client).map(&:length).max),
      project.name.to_s.ljust(@projects.map(&:name).map(&:length).max),
      task.name.to_s.ljust(@projects.map(&:tasks).flatten.map(&:name).map(&:length).max),
      ("%.2f" % hours).to_s.rjust(5),
      notes
    ].join(" | ")
  end

  def post(handle, date, hours, notes)
    project = find(handle) || @projects.first
    task = project.tasks.first
    @harvest.time.create Harvest::TimeEntry.new(
      notes: notes,
      hours: hours,
      spent_at: date,
      project_id: project.id,
      task_id: project.tasks.first.id
    )
  end
end
