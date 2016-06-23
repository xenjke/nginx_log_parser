class ProgressBar
  def initialize(units=60)
    @units = units.to_f
  end

  def print(completed, total)
    norm = 1.0 / (total / @units)
    progress = (completed * norm).ceil
    pending = @units - progress
    Kernel.print "[#{'=' * progress }#{' ' * (pending)}] #{percentage(completed, total)}%\r"
  end

  def percentage(completed, total)
    ((completed / total.to_f) * 100).round
  end
end