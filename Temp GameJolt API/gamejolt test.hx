import sys.Http;
import haxe.crypto.Md5;

import haxe.io.Bytes;
import haxe.crypto.Base64;
import haxe.crypto.BaseCode;

import funkin.editors.ui.UIState;
import funkin.backend.system.Main;

import funkin.backend.assets.ModsFolder;

public function getGameJoltName() { return Base64.decode(Assets.getText(Paths.getPath("Temp GameJolt API/TOKEN"))).toString(); }

public var GameJolt = {
	http: new Http(''),
	id: 901749,
	privateKey: getGameJoltName(),

	username: 'ItsLJcool',
	token: 'DxQYfX', // dont try shit lmao, this is being refreshed when i make source public. Losor!!
	/**
		@param endpoint [String] - The API Endpoint you are trying to fetch, example: `users`
		@param params `{name:String, value:String}` - Data you are sending for the API to recieve. Example: `{name: "username", value: "ItsLJcool"}`
	**/
	get: function(endpoint:String, params:Array<{name:String, value:String}>) {
		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + endpoint + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(false);
		
		return Json.parse(GameJolt.http.responseData);
	},

	set: function(endpoint:String, params:Array<{name:String, value:String}>) {
		var url:String = 'https://api.gamejolt.com/api/game/v1_2/' + endpoint + '/?game_id=' + GameJolt.id;
		for (i in params)
			url += '&' + Std.string(i.name) + '=' + Std.string(i.value);
		var urlEncoded:String = Md5.encode(url + GameJolt.privateKey);
		GameJolt.http.url = url + '&signature=' + urlEncoded;
		GameJolt.http.request(true);
		
		return Json.parse(GameJolt.http.responseData);
	},

	setSave: function(key:String, save) { return GameJolt.set("data-store/set", [{name: "key", value: key}, {name: "data", value: save }]); },
	setUserSave: function(key:String, save) {
		return GameJolt.set("data-store/set", [
			{name: "key", value: key}, {name: "data", value: save },
			{name: "username", value: GameJolt.username }, {name: "user_token", value: GameJolt.token }
		]);
	},
	getSave: function(key:String) { return GameJolt.get("data-store", [{name: "key", value: key}]); },
	getUserSave: function(key:String) {
		return GameJolt.set("data-store", [
			{name: "key", value: key},
			{name: "username", value: GameJolt.username }, {name: "user_token", value: GameJolt.token }
		]);
	},

	lastUnlockedTrophy: null,
	unlockTrophy: function(trophyId) {
		var id:Int = trophyId;
		Main.execAsync(function() {
			var trophy = GameJolt.get('trophies', [{name: 'username', value: GameJolt.username}, {name: 'user_token', value: GameJolt.token}, {name: 'trophy_id', value: id}]).response.trophies[0];
            trace(trophy);
			if (!trophy.achieved) {
				GameJolt.set('trophies/add-achieved', [{name: 'username', value: GameJolt.username}, {name: 'user_token', value: GameJolt.token}, {name: 'trophy_id', value: id}]);
				GameJolt.lastUnlockedTrophy = trophy;
				// Play Trophy SFX (placeholder rn)
				FlxG.sound.play(Paths.sound("Notification"), 1);
			}
		});
	}
};