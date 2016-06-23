class Request
  attr_accessor :data, :line
  attr_accessor :up_status, :date, :response_time, :method, :query_string, :url

  def initialize(line)
    @line = line
    parse(line)
  end

  private

  def parse(line)
    @up_status = parse_up_status
    @date = parse_date
    @response_time = parse_response_time
    @url = parse_url
    @method = parse_method

  end

  def parse_method
    return nil unless url
    m = case url
          when /images/
            'images'
          when /voucher/
            'voucher'
          else
            url.include?('?') ? @url.split('?').first : url
        end
    m.split(' ').first
  end

  def parse_url
    regex = /"(GET|POST|HEAD)\s(.*?)"/
    _, type, url = *line.match(regex)
    #@method = @url.include?('?') ? @url.split('?').first : @url
    #@query_string = @url.include?('?') ? @url.split('?')[1..-1].join : @url
    url
  rescue
    puts line
  end

  def parse_up_status
    match = line.match(/up_status="(\d*)"/)
    match ? match[1].to_i : nil
  end

  def parse_date
    match = line.match(/\[([^\]]+)\]/)
    date_string = match ? match[1] : nil
    begin
      date = DateTime.parse(date_string.sub(':', ' '))
    rescue => e
      puts string
      puts e
    end
    date
  end

  def parse_response_time
    match = line.match(/up_resp_time="(\d*)"/)
    time_string = match ? match[1] : nil
    time_string.to_f
  end

end