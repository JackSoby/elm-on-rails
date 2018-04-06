module Main exposing (..)

import RemoteData exposing (WebData, RemoteData(..))
import Http
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (value, class, placeholder, id)
import Json.Decode as Decode exposing (field, Decoder, int, string)
import Json.Encode as Encode
import RemoteData.Http exposing (..)


--main function


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { input : String
    , todos : List String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [], getTodos )


type Msg
    = AddTodo
    | HandleTextInput String
    | LoadAll (Result Http.Error (List String))
    | UpdateTodoList (Result Http.Error String)
    | DeleteTodo String
    | UpdateDeletedTodos (WebData String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTodo ->
            ( Model "" model.todos, encodeTodo model.input )

        HandleTextInput nextInput ->
            ( { model | input = nextInput }, Cmd.none )

        LoadAll (Ok allTodos) ->
            ( { model | input = "", todos = allTodos }, Cmd.none )

        LoadAll (Err error) ->
            let
                errorText =
                    Debug.log "error: " error
            in
                ( model, Cmd.none )

        UpdateTodoList (Ok todo) ->
            ( { model | input = "", todos = todo :: model.todos }, Cmd.none )

        UpdateTodoList (Err error) ->
            let
                errorText =
                    Debug.log "error: " error
            in
                ( model, Cmd.none )

        DeleteTodo toBeDeleted ->
            ( Model "" model.todos, encodeDeletedTodo toBeDeleted )

        UpdateDeletedTodos allTodos ->
            ( { model | input = "", todos = model.todos }, getTodos )


view : Model -> Html Msg
view model =
    let
        renderedTodos =
            model.todos
                |> List.map (\todo -> div [ class "single-todo" ] [ text todo, span [ id todo, class "crud" ] [ text "Update" ], span [ onClick (DeleteTodo todo), class "crud" ] [ text "Delete" ] ])
    in
        div [ class "elm-container" ]
            [ div [ class "other-body" ]
                [ div [ class "form-div" ]
                    [ form []
                        [ input [ placeholder "Write something...", class "input-field", onInput HandleTextInput, value model.input ] []
                        , div [ class "button", onClick AddTodo ] [ text "Add Todo" ]
                        ]
                    ]
                ]
            , h1 [ class "todo-banner" ] [ text "Todos" ]
            , div [ class "rendered-todos" ] renderedTodos
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


getTodos : Cmd Msg
getTodos =
    Http.send LoadAll (Http.get "api/v1/todos" decodeTodoList)


encodeTodo : String -> Cmd Msg
encodeTodo todo =
    let
        encodedTodo =
            Encode.object
                [ ( "name", Encode.string todo ) ]
    in
        newTodo encodedTodo


encodeDeletedTodo : String -> Cmd Msg
encodeDeletedTodo todo =
    let
        encodedTodo =
            Encode.object
                [ ( "name", Encode.string todo ) ]
    in
        oldTodo encodedTodo


oldTodo : Decode.Value -> Cmd Msg
oldTodo todo =
    delete "/api/v1/todos/:id" UpdateDeletedTodos (todo)


newTodo : Encode.Value -> Cmd Msg
newTodo userInput =
    let
        body =
            userInput
                |> Http.jsonBody
    in
        Http.send UpdateTodoList (Http.post "api/v1/todos" body (decodeText))


decodeTodoList : Decode.Decoder (List String)
decodeTodoList =
    Decode.list decodeText


decodeText : Decode.Decoder String
decodeText =
    Decode.at [ "name" ] Decode.string
    
