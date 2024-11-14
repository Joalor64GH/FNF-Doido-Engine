package backend.system;

import Date;
#if debug
import flixel.system.debug.log.LogStyle;
#end

/*
	New Logs system is here!

    This is our new fancy way of doing traces, with some cool colors and flair!
    To use, simply do Logs.print("your text"); There are also some extra things
    that allow you to customize your prints even further, such as types! You can
    check out the code to learn more! Page on the Wiki soon!

	- teles
*/

enum ErrorType {
    TRACE;
    WARNING;
    ERROR;
    HSCRIPT;
}

class Logs {
    public static var separator:String = ' | ';

    public static var colorMap:Map<ErrorType, Array<Dynamic>> = [
        TRACE    => [92, "16C60C"],
        WARNING  => [93, "D7FC04"],
        ERROR    => [91, "D60D0D"],
        HSCRIPT  => [94, "0000FF"],
    ];

    public static function print(v:Dynamic, type:ErrorType = TRACE, printType:Bool = true, printTime:Bool = true, printClass:Bool = true, allowDebugger:Bool = true, ?infos:Null<haxe.PosInfos>) {
        #if !ENABLE_PRINTING
        return;
        #end

        #if debug
        if(allowDebugger) {
            var style:LogStyle = new LogStyle("", colorMap.get(type)[1]);
            FlxG.log.advanced(formatOutput(v, type, printType, printTime, printClass, false, infos), style);
        }
        #end

		#if sys
		Sys.println(formatOutput(v, type, printType, printTime, printClass, true, infos));
		#elseif html5
        if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(formatOutput(v, type, printType, printTime, printClass, true, infos));
        #end
    }

    public static function formatType(type:ErrorType = TRACE) {
        return switch(type) {
            case WARNING: "[WARNING]";
            case ERROR: "[ ERROR ]";
            default: "[ TRACE ]";
        }
    }

    public static function formatOutput(v:Dynamic, type:ErrorType, printType:Bool = true, printTime:Bool = true, printClass:Bool = true, hasColor:Bool = true, infos:Null<haxe.PosInfos>):String {
        var str:String = "";

        if(printType) {
            if(hasColor) str += '\x1b[${colorMap.get(type)[0]}m';
            str += formatType(type);
            if(hasColor) str += '\x1b[97m';
            str += separator;
        }

        if(printTime)
            str += Date.now().toString().split(' ')[1] + separator;

        if(printClass)
            str += infos.className + ':' + infos.lineNumber + separator;

        str += Std.string(v);

        if (infos.customParams != null) {
            for (i in infos.customParams) {
                str += Std.string(i);
            }
        }

        return str;
    }
}