module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (value, class, placeholder)

--main function
main =
    Html.beginnerProgram { view = view
                        , model = model
                        , update = update
                        }


type alias Model =
  { input: String
  , todos: List String
  }


model : Model
model =
    { input = ""
    , todos = []
    }

type Msg
    = AddTodo
    | HandleTextInput String


update : Msg -> Model -> Model
update msg model =
    case msg of
        AddTodo ->
          { model | input = "", todos = model.input :: model.todos }
        HandleTextInput nextInput ->
          {model | input = nextInput }


view : Model -> Html Msg
view model =
  let
    renderedTodos = model.todos
      |> List.map (\todo -> div [class "single-todo"] [text todo, span [class "crud"] [text "Update"], span [class "crud"] [text "Delete"]])
  in
  div [class "elm-container"] [
    div [class"other-body"] [
      div [ class "form-div"]
            [
              form [ ] [
                input [ placeholder "Write something...", class "input-field", onInput HandleTextInput, value model.input ] []
                , div [ class "button", onClick AddTodo ] [text "Add Todo"]
            ]
          ]
        ],
        h1 [class "todo-banner"] [ text "Todos"],
        div [class "rendered-todos"] renderedTodos

      ]
