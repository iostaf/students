#############################################################################
#
# Filename: School.rb
# Purpose:  Minimal Rack-based REST server to provide test data for
#           students iPhone application.
#
#############################################################################

require 'json'

class JsonDataProvider
	def initialize()
		@students = {:students => [{:id => 1, :fname => 'Ivan', :lname => 'Ostafiychuk'},
								   {:id => 2, :fname => 'Oleg', :lname => 'Khomey'}]}
	end

	def add_john_doe
		@students[:students] << {:id => 3, :fname => 'John', :lname => 'Doe'}
	end

	def list_students()
		@students.to_json
	end

	def delete_student_with_key(key)
		@students[:students].delete_if {|a| a[:id] == key }
	end
end

class SchoolServer
	def tellme(message)
		puts '[TELLME] ' + message
	end

	def call(env)
		@students = JsonDataProvider.new;
		@req = Rack::Request.new(env)
		case @req.path
			when '/' then [200, {'Content-Type' => 'text/html'}, ['index']]
			when '/students' then
				if @req.get?
					tellme 'Get list of students.'
					[200, {'Content-Type' => 'application/json'}, [@students.list_students()]]
				elsif @req.post?
					@students.add_john_doe()
					tellme 'New student created.'
					[200, {'Content-Type' => 'application/json'}, []]
				end
			else
				if @req.path =~ /^\/students\/(\d+)/i
					student_id = $1
					if @req.delete?
						tellme 'Student with :id => ' + student_id + ' was deleted.'
						@students.delete_student_with_key(student_id)
						[200, {'Content-Type' => 'application/json'}, []]
					elsif @req.put?
						tellme 'Student with :id => ' + student_id + ' was updated.'
						[200, {'Content-Type' => 'application/json'}, []]
					else
						[404, {'Content-Type' => 'text/html'}, ['Page Not Found']]
					end
				else
					[404, {'Content-Type' => 'text/html'}, ['Page Not Found']]
				end
		end
	end
end
