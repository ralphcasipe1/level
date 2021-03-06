module Route exposing (Route(..), fromUrl, href, isCurrent, parser, pushUrl, replaceUrl, toLogin, toSpace, toString)

{-| Routing logic for the application.
-}

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Route.Apps
import Route.Group
import Route.GroupSettings
import Route.Groups
import Route.Help
import Route.NewGroupPost
import Route.NewPost
import Route.Posts
import Route.Search
import Route.Settings
import Route.SpaceUser
import Route.SpaceUsers
import Route.WelcomeTutorial
import Url exposing (Url)
import Url.Builder as Builder exposing (absolute)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, top)



-- ROUTING --


type Route
    = Home
    | Spaces
    | NewSpace
    | Root String
    | Posts Route.Posts.Params
    | SpaceUsers Route.SpaceUsers.Params
    | SpaceUser Route.SpaceUser.Params
    | InviteUsers String
    | Groups Route.Groups.Params
    | Group Route.Group.Params
    | NewGroupPost Route.NewGroupPost.Params
    | NewGroup String
    | GroupSettings Route.GroupSettings.Params
    | Post String String
    | NewPost Route.NewPost.Params
    | UserSettings
    | Settings Route.Settings.Params
    | Search Route.Search.Params
    | WelcomeTutorial Route.WelcomeTutorial.Params
    | Help Route.Help.Params
    | Apps Route.Apps.Params


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home (s "home")
        , Parser.map Spaces (s "teams")
        , Parser.map NewSpace (s "teams" </> s "new")
        , Parser.map Root Parser.string
        , Parser.map Posts Route.Posts.parser
        , Parser.map SpaceUsers Route.SpaceUsers.parser
        , Parser.map SpaceUser Route.SpaceUser.parser
        , Parser.map InviteUsers (Parser.string </> s "invites")
        , Parser.map Groups Route.Groups.parser
        , Parser.map NewGroup (Parser.string </> s "channels" </> s "new")
        , Parser.map GroupSettings Route.GroupSettings.parser
        , Parser.map Group Route.Group.parser
        , Parser.map NewGroupPost Route.NewGroupPost.parser
        , Parser.map NewPost Route.NewPost.parser
        , Parser.map Post (Parser.string </> s "posts" </> Parser.string)
        , Parser.map UserSettings (s "user" </> s "settings")
        , Parser.map Settings Route.Settings.parser
        , Parser.map Search Route.Search.parser
        , Parser.map WelcomeTutorial Route.WelcomeTutorial.parser
        , Parser.map Help Route.Help.parser
        , Parser.map Apps Route.Apps.parser
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href route =
    Attr.href (toString route)


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (toString route)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


toLogin : Cmd msg
toLogin =
    Nav.load "/login"


toSpace : String -> Cmd msg
toSpace slug =
    Nav.load ("/" ++ slug ++ "/")


isCurrent : Route -> Maybe Route -> Bool
isCurrent testRoute maybeCurrentRoute =
    case ( testRoute, maybeCurrentRoute ) of
        ( Posts testParams, Just (Posts currentParams) ) ->
            Route.Posts.getAuthor testParams
                == Route.Posts.getAuthor currentParams
                && Maybe.map List.sort (Route.Posts.getRecipients testParams)
                == Maybe.map List.sort (Route.Posts.getRecipients currentParams)

        ( Settings _, Just (Settings _) ) ->
            True

        ( Group params, Just (Group currentParams) ) ->
            if Route.Group.hasSamePath params currentParams then
                True

            else
                False

        ( Groups _, Just (Groups _) ) ->
            True

        ( route, Just currentRoute ) ->
            if route == currentRoute then
                True

            else
                False

        ( _, _ ) ->
            False


toString : Route -> String
toString page =
    case page of
        Home ->
            absolute [ "home" ] []

        Spaces ->
            absolute [ "teams" ] []

        NewSpace ->
            absolute [ "teams", "new" ] []

        Root slug ->
            absolute [ slug ] []

        Posts params ->
            Route.Posts.toString params

        SpaceUser params ->
            Route.SpaceUser.toString params

        SpaceUsers params ->
            Route.SpaceUsers.toString params

        InviteUsers slug ->
            absolute [ slug, "invites" ] []

        Groups params ->
            Route.Groups.toString params

        Group params ->
            Route.Group.toString params

        NewGroupPost params ->
            Route.NewGroupPost.toString params

        NewGroup slug ->
            absolute [ slug, "channels", "new" ] []

        GroupSettings params ->
            Route.GroupSettings.toString params

        Post slug id ->
            absolute [ slug, "posts", id ] []

        NewPost params ->
            Route.NewPost.toString params

        UserSettings ->
            absolute [ "user", "settings" ] []

        Settings params ->
            Route.Settings.toString params

        Search params ->
            Route.Search.toString params

        WelcomeTutorial params ->
            Route.WelcomeTutorial.toString params

        Help params ->
            Route.Help.toString params

        Apps params ->
            Route.Apps.toString params
