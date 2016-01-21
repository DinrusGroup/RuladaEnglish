import auxd.ray.video.DisplayMode, tango.io.Stdout;;
void main() {
		bool	r;

		assert( !DisplaySettings.modified );
		r = DisplaySettings.change( true );		// redundant change
		assert( r == true );

		static bool print( DisplayMode mode ) {
			with ( mode ) {
				Stdout.format( "режим: {0} на {1}, глубина цвета: {2}, при {3} Гц", width, height, bitdepth, frequency ).newline;
			}
			return true;
		}

		Stdout( "Выводим все поддерживаемые режимы показа:" ).newline;
		DisplaySettings.enumerate( &print );

		Stdout( "устанавливаем безопасный режим (строго):" ).newline;
		r = DisplaySettings.change( true, 640, 480, 16, 70 );
		if ( !r ) {
			Stdout( "устанавливаем безопасный режим (ослабленно):" ).newline;
			r = DisplaySettings.change( false, 640, 480, 16, 0 );
		}
		else {
			r = DisplaySettings.change( true, 640, 480, 16, 0 );
		}
		if ( !r ) {
			Stdout( "неудачно" ).newline;
		}
		else {
			Stdout( "устанавливаем самый высокий режимe (строго):" ).newline;
			r = DisplaySettings.change( true, 2048, 1536, 32, 150 );
			if ( !r ) {
				Stdout( "устанавливаем самый высокий режим (ослабленно):" ).newline;
				r = DisplaySettings.change( false, 2048, 1536, 32, 150 );
			}
		}

		if ( DisplaySettings.modified ) {
			Stdout( "восстанавливаем режим отображения" ).newline;
			DisplaySettings.restore;
		}
	}