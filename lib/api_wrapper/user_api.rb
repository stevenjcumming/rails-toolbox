module ApiWrapper
  class UserApi < Base
    def index
      response = self.class.get('/users', headers: @headers)
      parse_response(response)
    end

    def show(id)
      response = self.class.get("/users/#{id}", headers: @headers)
      parse_response(response)
    end

    def create(data)
      response = self.class.post('/users', headers: @headers, body: data.to_json)
      parse_response(response)
    end

    def update(id, data)
      response = self.class.put("/users/#{id}", headers: @headers, body: data.to_json)
      parse_response(response)
    end

    def destroy(id)
      response = self.class.delete("/users/#{id}", headers: @headers)
      parse_response(response)
    end
  end
end

# Usage 
user_api = ApiWrapper::UserApi.new
users = user_api.index
