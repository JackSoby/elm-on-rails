class Api::V1::TodosController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    todos = Todo.all
    render json: todos.sort.reverse
  end
  
  def create
    newTodo = Todo.new(name: params["name"])
    if(newTodo.save)
      render json: neTwodo
    else
      render json: "todo did not save"
    end
  end

  def destroy
    Todo.where(name: params[:name]).destroy_all
    render json: "tod deleted"
  end

end
