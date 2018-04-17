module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, value)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, string)
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..), WebData)
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
    , todos : List Todo
    , editingTodo : Maybe Int
    }


type alias Todo =
    { id : Int, name : String }


init : ( Model, Cmd Msg )
init =
    ( Model "" [] Nothing, getTodos )


type Msg
    = AddTodo
    | HandleTextInput String
    | LoadAll (Result Http.Error (List Todo))
    | UpdateTodoList (Result Http.Error Todo)
    | DeleteTodo Todo
    | UpdateTodo Todo
    | UpdateDeletedTodos (WebData String)
    | UpdateUpdatedTodos (WebData Todo)
    | SaveUpdatedTodo Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddTodo ->
            ( Model "" model.todos Nothing, encodeTodo model.input )

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
            ( Model "" model.todos Nothing, encodeDeletedTodo toBeDeleted )

        UpdateUpdatedTodos allTodos ->
            ( { model | input = "" }, getTodos )

        UpdateDeletedTodos allTodos ->
            ( { model | input = "" }, getTodos )

        UpdateTodo todo ->
            ( { model | input = todo.name, editingTodo = Just todo.id }, Cmd.none )

        SaveUpdatedTodo todoId ->
            ( { model | input = "" }, sendUpdatedTodo { id = todoId, name = model.input } )


view : Model -> Html Msg
view model =
    let
        renderedTodos =
            model.todos
                |> List.map (\todo -> div [ class "single-todo" ] [ text todo.name, span [ onClick (UpdateTodo todo), class "crud" ] [ text "Update" ], span [ onClick (DeleteTodo todo), class "crud" ] [ text "Delete" ] ])

        submitButton =
            case model.editingTodo of
                Just todoId ->
                    div [ class "button", onClick (SaveUpdatedTodo todoId) ] [ text "Update Todo" ]

                Nothing ->
                    div [ class "button", onClick AddTodo ] [ text "Add Todo" ]
    in
    div [ class "elm-container" ]
        [ div [ class "other-body" ]
            [ div [ class "form-div" ]
                [ form []
                    [ input [ placeholder "Write something...", class "input-field", onInput HandleTextInput, value model.input ] []
                    , submitButton
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


encodeDeletedTodo : Todo -> Cmd Msg
encodeDeletedTodo todo =
    let
        encodedTodo =
            Encode.object
                [ ( "id", Encode.int todo.id )
                , ( "name", Encode.string todo.name )
                ]
    in
    oldTodo encodedTodo


oldTodo : Decode.Value -> Cmd Msg
oldTodo todo =
    delete "/api/v1/todos/:id" UpdateDeletedTodos todo


encodeUpdatedTodo : Todo -> Encode.Value
encodeUpdatedTodo todo =
    Encode.object
        [ ( "id", Encode.int todo.id )
        , ( "name", Encode.string todo.name )
        ]


sendUpdatedTodo : Todo -> Cmd Msg
sendUpdatedTodo todo =
    put "/api/v1/todos/:id" UpdateUpdatedTodos decodeText (encodeUpdatedTodo todo)


newTodo : Encode.Value -> Cmd Msg
newTodo userInput =
    let
        body =
            userInput
                |> Http.jsonBody
    in
    Http.send UpdateTodoList (Http.post "api/v1/todos" body decodeText)


decodeTodoList : Decode.Decoder (List Todo)
decodeTodoList =
    Decode.list decodeText


decodeText : Decode.Decoder Todo
decodeText =
    Decode.map2 Todo
        (field "id" int)
        (field "name" string)
