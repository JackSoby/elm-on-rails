class Api::V1::TodosController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    todos = Todo.all
    render json: todos.sort.reverse
  end
  
  def create
    newTodo = Todo.new(name: params["name"])
    if(newTodo.save)
      render json: newTodo
    else
      render json: "todo did not save"
    end
  end

  def destroy
    todo = Todo.find_by(id: params["todo"]['id'])
    todo.destroy
    render json: "todo deleted"
  end

  def update
    todo = Todo.find_by(id: params["todo"]['id'])
    todo.update(name: params["todo"]['name'])
    render json: todo
  end
end
