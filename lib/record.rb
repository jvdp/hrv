class Record
  REGEXES = {
    synced: /^---.*$/,
    day: /
      ^(?<dayno>\d{1,2})
      \s+
      (?<month>[a-z]+)
      .*$
    /xi,
    entry: /
      ^(?<from>\d\d:\d\d)
      \s+-\s+
      (?<to>\d\d:\d\d)
      \s+
      (?<task>\S+)
      \s*
      (?<desc>[^#]*)
      .*$
    /x
  }

  attr_reader :lines, :synced

  def initialize(io)
    @lines = []
    @synced = true
    @day = nil
    io.each_line &method(:parse_line)
  end

  def synced?
    entries.all?(&:synced?)
  end

  def sync(tasks)
    @lines.reject(&:synced?).each {|l| l.sync(tasks) }
  end

  def entries
    @lines.select {|l| l.is_a? Entry }
  end

  def write(out = $stdout)
    synced = true
    @lines.each do |line|
      if synced && !line.synced
        synced = false
        out.puts "-" * 80
      end
      out.puts line.to_s.rstrip
    end
    out.puts "-" * 80 if synced
  end

  private
  def parse_line(line)
    case line
    when REGEXES[:synced]
      @synced = false
    when REGEXES[:day]
      add_line @day = Day.new($~)
    when REGEXES[:entry]
      add_line @day.new_entry($~)
    else
      add_line Line.new(line)
    end
  end

  def add_line(line)
    @lines << line.tap {|l| l.synced = @synced }
  end

  class Line
    attr_accessor :synced
    alias synced? synced

    def initialize(line)
      @line = line
    end
    def to_s
      @line
    end
    def sync(*)
      @synced = true
    end
  end

  class Entry < Line
    def initialize(match, day)
      super match.to_s
      @from = Time.parse(match[:from], day)
      @to   = Time.parse(match[:to],   day)
      @to   = Time.parse(match[:to],   day + 1) if @to < @from
      @task = match[:task]
      @desc = match[:desc].length > 0 ? match[:desc] : @task
      @synced = false
    end

    def dump(tasks)
      tasks.dump(@task, @from, hours, @desc)
    end

    def sync(tasks)
      dump tasks
      tasks.post(@task, @from, hours, @desc)
      super
    end

    def hours
      (@to - @from) / 3600
    end
  end

  class Day < Line
    MONTHS = %w[_ januari februari maart april mei juni juli augustus september oktober november december]

    def initialize(match)
      @date = Date.new(Date.today.year, MONTHS.index(match[:month].downcase), match[:dayno].to_i)
      @entries = []
    end

    def new_entry(match)
      Entry.new(match, @date).tap {|e| @entries << e }
    end

    def hours
      @entries.map(&:hours).inject(:+) || 0
    end

    def to_s
      "%s %s (%.2f uur)" % [@date.day, MONTHS[@date.month], hours]
    end
  end
end
