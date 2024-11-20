package backend.song;

import flixel.*;
import openfl.Lib;

#if sys
import sys.io.File;
#end

import crowplexus.iris.Iris;
import crowplexus.iris.IrisConfig;

using StringTools;

class Hscript extends FlxBasic {
    public var script:Iris;

    public function new(file:String) {
        super();

        final rules:RawIrisConfig = {name: "hscript-iris", autoRun: false, autoPreset: true};

        script = new Iris(File.getContent(file), rules);
        script.preset();

        script.set('import', function(daClass:String, ?asDa:String) {
			final splitClassName:Array<String> = [for (e in daClass.split('.')) e.trim()];
			final className:String = splitClassName.join('.');
			final daClass:Class<Dynamic> = Type.resolveClass(className);
			final daEnum:Enum<Dynamic> = Type.resolveEnum(className);

			if (daClass == null && daEnum == null)
				Lib.application.window.alert('Class / Enum at $className does not exist.', 'Hscript Error!');
			else {
				if (daEnum != null) {
					var daEnumField = {};
					for (daConstructor in daEnum.getConstructors())
						Reflect.setField(daEnumField, daConstructor, daEnum.createByName(daConstructor));

					if (asDa != null && asDa != '')
						setVariable(asDa, daEnumField);
					else
						setVariable(splitClassName[splitClassName.length - 1], daEnumField);
				} else {
					if (asDa != null && asDa != '')
						setVariable(asDa, daClass);
					else
						setVariable(splitClassName[splitClassName.length - 1], daClass);
				}
			}
		});

		script.set('trace', function(value:Dynamic) {
			trace(value);
		});

        script.set('game', PlayState.instance);

        script.set('add', function(obj:FlxBasic) {
            return PlayState.instance.add(obj);
        });
        script.set('remove', function(obj:FlxBasic) {
            return PlayState.instance.remove(obj);
        });

        script.set('Paths', PlayState.instance);

        script.execute();
    }

    public function call(name:String, ?args:Array<Dynamic> = []) {
        script.call(name, args);
    }
}