module Rack
	class CommonLogger
		def call(env)
			# do nothing
			@app.call(env)
		end
	end
end


# Many thanks to @kballenegger and the "rake-json-logs" gem
# https://github.com/kballenegger/rack-json-logs

require "json"
require "stringio"
require "socket"

module Rack
	class JSONLogger

		def initialize(app, options={})
			@app = app
			@options = {
				reraise_exceptions: true,
				print_options: { trace: true },
				capture_stdout: false
			}.merge(options)
			@options[:from] ||= Socket.gethostname
		end

		def call(env)
			start_time = Time.now

			if @options[:capture_stdout]
				$stdout, previous_stdout = (stdout_buffer = StringIO.new), $stdout
				$stderr, previous_stderr = (stderr_buffer = StringIO.new), $stderr
			end

			logger = EventLogger.new(start_time)

			env = env.dup
			env[:logger] = logger

			begin
				response = @app.call(env)
			rescue Exception => e
				exception = e
			end

			params = {}
			if env["QUERY_STRING"].present?
				params.merge!(Rack::Utils.parse_nested_query(env["QUERY_STRING"]))
			end
			post_data = env['rack.input'].read
			if post_data.present?
				params.merge!(JSON.parse(post_data))
			end

			log = {
				time:		start_time.to_i,
				method:		env["REQUEST_METHOD"],
				path: 		env["PATH_INFO"],
				status:	 	(response || [500]).first,
				duration: 	(Time.now - start_time).round(3),
				params: 	params,
				from:		@options[:from]
			}

			if env["HTTP_TRANSIT_RID"].present?
				log[:transit_rid] = env["HTTP_TRANSIT_RID"]
			end
			if env["HTTP_TRANSIT_UID"].present?
				log[:transit_uid] = env["HTTP_TRANSIT_UID"]
			end

			if @options[:capture_stdout]
				# restore output IOs
				$stderr = previous_stderr
				$stdout = previous_stdout
				
				log[:stdout] = stdout_buffer.string
				log[:stderr] = stderr_buffer.string
			end

			log[:events] =	logger.events if logger.used
			if exception
				log[:exception] = {
					message:	 exception.message,
					backtrace: exception.backtrace
				}
			end

			STDOUT.puts(log.to_json)

			raise exception if exception && @options[:reraise_exceptions]

			response || response_500
		end

		def response_500
			[500, {"Content-Type" => "application/json"},
			 [{status: 500, message: "Something went wrong..."}.to_json]]
		end


		# This class can be used to log arbitrary events to the request.
		#
		class EventLogger
			attr_reader :events, :used

			def initialize(start_time)
				@start_time = start_time
				@events		 = []
				@used			 = false
			end

			# Log an event of type `type` and value `value`.
			#
			def log(type, value)
				@used = true
				@events << {
					type:	type,
					value: value,
					time:	(Time.now - @start_time).round(3)
				}
			end
		end
	end
end

