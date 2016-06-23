class Log
  attr_accessor :requests, :codes_count, :date_start, :date_end
  attr_reader :file_path

  def initialize(log_file_path)
    @file_path = log_file_path
    @requests = []
    @codes_count = Hash.new { |hash, key| hash[key] = 0 }
  end

  def parse
    size_of_file = File.size(file_path)
    bytes_processed = 0
    progress_bar = ProgressBar.new

    puts "Parsing file #{file_path}"

    File.open(file_path).each_line do |line|
      progress_bar.print(bytes_processed, size_of_file)
      request = Request.new(line)
      requests << request

      codes_update(request)
      calculate_log_date_range(request)

      bytes_processed += line.bytesize

      #break
    end

    puts "\r\nDone parsing, gathered: #{requests.size} lines"
  end

  def calculate_log_date_range(request)
    date = request.date
    @date_start = date unless @date_start
    @date_end = date unless @date_end

    if date > date_start
      @date_end = date
    else
      @date_start = date
    end
  end

  def codes_update(request)
    codes_count[request.up_status] += 1 if request.up_status
  end

  def print_codes_count
    puts "Response codes in #{file_path}"
    puts "From #{date_start.strftime('%FT%T%:z')} to #{date_end.strftime('%FT%T%:z')}"
    puts JSON.pretty_unparse(codes_count)
  end

  def print_methods(print_limit)
    limit = print_limit ? print_limit : 100
    limit = -1 if print_limit && print_limit <= 0
    puts "Methods requested:"
    requests_collection = Hash.new { |hash, key| hash[key] = 0 }

    requests.map do |request|
      requests_collection[request.method] += 1 if request.method
    end

    out_hash = requests_collection.sort_by { |name, count| count }.reverse[0..limit].to_h
    puts JSON.pretty_unparse(out_hash)

  end

  def print_detailed_error_codes(codes=[500])
    puts "#{codes.join(',')} code requests:"
    codes << (500..600).to_a if codes.include?(500)
    codes.flatten!

    details = Hash.new { |k, v| k[v]= [] }
    requests.each do |r|
      if r.up_status && codes.include?(r.up_status)
        details[r.up_status] << [r.date, r.url]
      end
    end
    puts JSON.pretty_unparse(details)
  end

end