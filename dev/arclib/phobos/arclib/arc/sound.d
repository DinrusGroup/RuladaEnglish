/******************************************************************************* 

	Uses OpenAL to play Ogg and Wav files. 

	Authors:       ArcLib team, see AUTHORS file 
	Maintainer:    Clay Smith (clayasaurus at gmail dot com) 
	License:       zlib/libpng license: $(LICENSE) 
	Copyright:     ArcLib team 

	Special thanks to Eric Poggel (JoeCoder) for contributing his OpenAL playing code
	to ArcLib. 

	Description:    
		Uses OpenAL to play Ogg and Wav sound files. Use the SoundFile class to load 
	a sound file, and use the Sound class which takes a SoundFile argument to play 
	the loaded sound class. 


	Examples:
	--------------------
	import arc.sound;
	
	int main()
	{
		arc.sound.open();

		Sound snd = new Sound(new SoundFile("vorbis.ogg"));

		while(gameloop)
		{
			if (playSound)
			{
				snd.stop(); 
				snd.play();
			}

			snd.process(); 
		}
		
		arc.sound.close(); 
	}
	--------------------

*******************************************************************************/

module arc.sound; 

public import derelict.openal.al;

import 	
	derelict.ogg.vorbis, 
	derelict.ogg.ogg,
	derelict.util.exception;

import 	
	std.mmfile,
	std.c,
	//std.c,
	//std.c,
	std.gc,
	std.string;

import 
	arc.log,
	arc.types,
	arc.math.routines,
	arc.math.point;
	
static import arc.templates.array;
import std.io;

public 
{
	/// Open OpenAL device 
	void open()
	{
		loadDerelict();        
        
		// Initialize OpenAL audio
		al_device = alcOpenDevice(null);
		al_context = alcCreateContext(al_device, null);
		alcMakeContextCurrent(al_context);

		if (alGetError() != 0 || al_device == null || al_context == null)
		{
			soundInitialized = false; 
			throw new Exception("There was an error when initializing OpenAL.");
		}
		else
		{
			soundInitialized = true;
		}
		
		// default initial values for listener 
		setListenerPosition(Point(0,0));
		setListenerVelocity(Point(0,0));
		setListenerOrientation(Point(0,0));
    
		// make sure sound is 'on'
		on();
	}
    
	/// Close OpenAL device 
	void close()
	{
		if(!soundInitialized)
			return;
		
		alcDestroyContext(al_context);
		alcCloseDevice(al_device);
		al_context = al_device = null;
		
		unloadDerelict(); 
	}
	
	/// calls process on all sounds
	void process()
	{
		foreach(sound; soundList)
		{
			if(!sound.paused)
				sound.process();
		}
	}
    
	/// turn sound on 
	void on()
	{
		if(soundInitialized)
			soundOn = true; 
		else
			soundOn = false; 
	}
	
	/// turn sound off
	void off()
	{
		soundOn = false;
	}
	
	/// tell if sound is on or off
	bool isSoundOn()
	{
		return soundOn;
	}
	
	bool isSoundInitialized()
	{
		return soundInitialized;
	}

	/// Set position of sound listener 
	void setListenerPosition(Point pos)
	{
		if(!soundInitialized)
			return;
			
		alListener3f(AL_POSITION, pos.x, pos.y, 0); 
	}

	/// Set velocity of listener 
	void setListenerVelocity(Point vel)
	{
		if(!soundInitialized)
			return;

		alListener3f(AL_VELOCITY, vel.x, vel.y, 0); 
	}

	/// set orientation of listener 
	void setListenerOrientation(Point ori)
	{
		if(!soundInitialized)
			return;		

		alListener3f(AL_ORIENTATION, ori.x, ori.y, 1); 
	}

	/// get listener position 
	Point getListenerPos()
	{
		if(!soundInitialized)
			return Point(0,0);
		
		float x, y;
		alGetListener3f(AL_POSITION, &x, &y, null); 
		return Point(x,y);
	}
	
	
	/// get listener velocity 
	Point getListenerVel()
	{
		if(!soundInitialized)
			return Point(0,0);
		
		float x, y; 
		alGetListener3f(AL_VELOCITY, &x, &y, null); 
		return Point(x,y);
	}

	/// get listener orientation 
	Point getListenerOri()
	{
		if(!soundInitialized)
			return Point(0,0);
		
		float x, y; 
		alGetListener3f(AL_ORIENTATION, &x, &y, null); 
		return Point(x,y);
	}
	
	/** 
		Makes a sound get processed when arc.sound.process is called.
		You must call unregisterAutoProcessSound (preferably in the destructor
		of the owning object): otherwise the sound can't get garbage collected
		and the sound might continue playing.
	**/
	void registerAutoProcessSound(Sound s)
	{
		soundList ~= s;
	}
	
	/// ditto
	void unregisterAutoProcessSound(Sound s)
	{
		arc.templates.array.remove(soundList, s);
	}
}

private 
{
	// Audio
	ALCdevice	*al_device;
	ALCcontext	*al_context;
	
	// sound list of all created sounds
	Sound[] soundList;
}



/// A class that emits a sound, not to be mistaken with a SoundFile.
class Sound
{	protected:

	uint		al_source;		// OpenAL index of this Sound Resource
	SoundFile		sound;			// The Sound Resource (file) itself.

	arcfl		pitch = 1.0;
	arcfl		radius = 256;	// The radius of the Sound that plays.
	arcfl		volume = 1.0;
	arcfl 	gain   = 1.0; 
	bool		looping = false;
	bool		paused  = false;	// true if paused or stopped

	int			size;			// number of buffers that we use at one time
	bool		enqueue = true;	// Keep enqueue'ing more buffers, false if no loop and at end of track.
	uint		buffer_start;	// the first buffer in the array of currently enqueue'd buffers
	uint		buffer_end;		// the last buffer in the array of currently enqueue'd buffers
	uint		to_process;		// the number of buffers to queue next time.

	public:
	/// open with sound file 
	this(SoundFile argSound)
	{
		if(soundInitialized)
		{		
			alGenSources(1, &al_source); 
			setSound(argSound); 
	
			setPaused(paused);
			setPitch(pitch);
			setGain(gain); 
			setLoop(looping); 
			setVolume(volume); 
			setRadius(radius);
		}
	}
	
	/// Destructor
	~this()
	{
		if (soundInitialized)
		{
			if(al_context != null)
			{ // Error if this is destructed after Device de-init.
				stop();
				alDeleteSources(1, &al_source);
			}
		}
	}
	
	/// Return the Sound Resource that this SoundNode plays.
	SoundFile getSound() 
	{
		if(!soundInitialized)
			return null;
			
		return sound;  
	}

	/// Set the Sound Resource that this SoundNode will play.
	void setSound(SoundFile _sound)
	{	
		if(!soundInitialized)
			return;
			
		bool tpaused = paused;
		stop();
		sound = _sound;

		// Ensure that our number of buffers isn't more than what exists in the sound file
		int len = sound.getBuffersLength();
		int sec = sound.getBuffersPerSecond();
		size = len < sec ? len : sec;
	}

	/// set gain of sound 
	void setGain(arcfl argGain)
	{
		if(!soundInitialized)
			return;
		
		alSourcef (al_source, AL_GAIN,     1.0f     );
	}

	/// set position of sound 
	void setPosition(Point pos)
	{
		if(!soundInitialized)
			return;
		
		alSource3f(al_source, AL_POSITION, pos.x, pos.y, 0); 
	}

	/// set velocity of sound
	void setVelocity(Point vel)
	{
		if(!soundInitialized)
			return;
		
		alSource3f(al_source, AL_VELOCITY, vel.x, vel.y, 0); 
	}

	/// Set the pitch of the SoundNode.
	arcfl getPitch(){	return pitch;	}

	/** Set the pitch of the SoundNode.
	 *  This has nothing to do with the frequency of the loaded Sound Resource.
	 *  \param pitch Less than 1.0 is deeper, greater than 1.0 is higher. */
	void setPitch(arcfl _pitch)
	{	
		if(!soundInitialized)
			return;
			
		pitch = _pitch;
		alSourcef(al_source, AL_PITCH, pitch);
	}

	/// Get the radius of the SoundNode
	arcfl getRadius() {	return radius; }

	/** Set the radius of the SoundNode.  The volume of the sound falls off at a rate of
	 *  inverse distance squared.  The default radius is 256.
	 *	\param The sound will be 1/2 its volume at this distance.
	 *  The accuracy of this code should probably be checked. */
	void setRadius(arcfl _radius)
	{	
		if(!soundInitialized)
			return;
			
		radius = _radius;
		alSourcef(al_source, AL_ROLLOFF_FACTOR, 1.0/radius);
	}

	/// Get the volume (gain) of the SoundNode
	arcfl getVolume() {	return volume; }

	/** Set the volume (gain) of the SoundNode.
	 *  \param volume 1.0 is the default. */
	void setVolume(arcfl _volume)
	{	
		if(!soundInitialized)
			return;
			
		volume = _volume;
		alSourcef(al_source, AL_GAIN, volume);
	}

	/// Does the Sound loop when playback is finished?
	bool getLooping() {	return looping;	}

	/// Set whether the playback of the SoundNode loops when playback is finished.
	void setLoop(bool _looping=true) { looping = _looping; }

	/// Is the sound currently paused (or stopped?)
	bool getPaused() { return paused; }

	/// Set whether the playback of the SoundNode is paused.
	void setPaused(bool _paused=true)
	{	
		if(!soundInitialized)
			return;
		
		// exit function if sound is turned off
		if (!soundOn)
			return;
        
        // Only do something if changing states
		if (paused != _paused)
		{	paused = _paused;
			if (paused)
				alSourcePause(al_source);
			else
			{	if (sound is null)
					throw new Exception("You cannot play or unpause a SoundNode without first calling setSound().");
				alSourcePlay(al_source);
				enqueue = true;
		}	}
	}

	/// Alias of setPaused(false);
	void play() { setPaused(false);	}

	/// Alias of setPaused(true);
	void pause(){ setPaused(true); }

	/** Seek to the position in the track.  Seek has a precision of .05 secs.
	 *  seek() throws an exception if the value is outside the range of the Sound */
	void seek(double seconds)
	{	
		if(!soundInitialized)
			return;
	
        if (sound is null)
			throw new Exception("You cannot seek a SoundNode without first calling setSound().");
		uint secs = cast(uint)(seconds*size);
		if (secs>sound.getBuffersLength())
			throw new Exception("SoundNode.seek("~.toString(seconds)~") is invalid for '"~sound.getSource()~"'");
		bool tpaused = paused;
		stop();
		buffer_start = buffer_end = secs;
		setPaused(tpaused);
	}

	/// Tell how many seconds we've played of the file
	double tell()
	{	
		if(!soundInitialized)
			return 0;
			
		int processed;
		alGetSourcei(al_source, AL_BUFFERS_PROCESSED, &processed);
		return ((buffer_start+processed) % sound.getBuffersLength())/cast(double)sound.getBuffersPerSecond();
	}

	/// Stop the SoundNode from playing and rewind it to the beginning.
	void stop()
	{	
		if(!soundInitialized)
			return;
		
		alSourceStop(al_source);
		paused		= true;
		enqueue		= false;

		// Delete any unused buffers
		int processed;
		alGetSourcei(al_source, AL_BUFFERS_PROCESSED, &processed);
		if (processed>0)
		{	//printf("Unqueuing buffers[%d..%d]\n", buffer_start, buffer_start+processed);
			alSourceUnqueueBuffers(al_source, processed, sound.getBuffers(buffer_start, buffer_start+processed).ptr);
			sound.freeBuffers(buffer_start, processed);
		}
		buffer_start = buffer_end = 0;
	}

	/** Enqueue new buffers for this SoundNode to play
	 *  Takes into account pausing, looping and all kinds of other things. */
	void updateBuffers()
	{
		if(!soundInitialized)
			return;
		
		if (enqueue)
		{	// Count buffers processed since last time we queue'd more
			int processed;
			alGetSourcei(al_source, AL_BUFFERS_PROCESSED, &processed);
			to_process = max(processed, cast(int)(size-(buffer_end-buffer_start)));

			// Update the buffers for this source
			if (to_process > size/32)
			{
				// If looping and our buffer has reached the end of the track
				int blength = sound.getBuffersLength();
				if (!looping && buffer_end+to_process >= blength)
					to_process = blength - buffer_end;

				// Unqueue old buffers
				if (processed > 0)	// new, ensure no bugs
				{	//writefln("Unqueuing buffers[%d..%d]", buffer_start, buffer_start+processed);
					alSourceUnqueueBuffers(al_source, processed, sound.getBuffers(buffer_start, buffer_start+processed).ptr);
					sound.freeBuffers(buffer_start, processed);
				}

				// Enqueue as many buffers as what are available
				//writefln("Enqueuing buffers[%d..%d]", buffer_end, buffer_end+to_process);
				sound.allocBuffers(buffer_end, to_process);
				alSourceQueueBuffers(al_source, to_process, sound.getBuffers(buffer_end, buffer_end+to_process).ptr);

				buffer_start+= processed;
				buffer_end	+= to_process;
			}
		}

		// If not playing
		int temp;
		alGetSourcei(al_source, AL_SOURCE_STATE, &temp);
		if (temp==AL_STOPPED || temp==AL_INITIAL)
		{	// but it should be, resume playback
			if (!paused && enqueue)
				alSourcePlay(al_source);
			else // we've reached the end of the track
			{	bool tpaused = paused;
				stop();
				if (looping && !tpaused)
					play();
			}
		}

		// This must be here for tracks with their total number of buffers equal to size.
		if (enqueue)
			// If not looping and our buffer has reached the end of the track
			if (!looping && buffer_end+1 >= sound.getBuffersLength())
				enqueue = false;	
	}

	/// Update overridden to update buffers.
	void process()
	{
		if(!soundInitialized)
			return;
		
		if (sound !is null)
			updateBuffers();	// where should this be called from?
	}
}

// Sound Resource Files //////////////////////////////////////////////////////////

/** A Sound is a represenation of sound data in system memory.
 *  Sounds use a BaseSoundFile as a member variable, which abstracts away
 *  the differences between different sound formats.
 *  During initialization, a Sound loads the sound data from a file and
 *  passes it on to OpenAL for playback, as it's needed. */
class SoundFile
{	protected:

	ubyte		format;  		// wav, ogg, etc.
	BaseSoundFile	sound_file;
	uint		al_format;		// Number of channels and uncompressed bit-rate.

	uint[]		buffers;		// holds the OpenAL id name of each buffer for the song
	uint[]		buffers_ref;	// counts how many SoundNodes are using each buffer
	uint		buffer_num;		// total number of buffers
	uint		buffer_size;	// size of each buffer in bytes, always a multiple of 4.
	uint		buffers_per_sec = 25;// ideal is between 5 and 500.  Higher values give more seek precision.
									// but limit the number of sounds that can be playing concurrently.

	public:

	/** Load a sound from a file.
	 *  Note that the file is not closed until the destructor is called.
	 *  \param source Filename of the sound to load.*/
	this(char[] filename)
	{
		if (soundInitialized)
		{	
			if (!std.file.exists(filename))
			{
				writefln("Sound File ", filename, " does not exist!"); 
			} 
	
			if (!(filename in soundFileList))
			{
				// Get first four bytes of sound file to determine type
				// And then load the file.  sound_file will have all of our important info
				MmFile file = new MmFile(filename);
				if (file[0..4]=="RIFF")
					sound_file = new WaveFile(filename);
				else if (file[0..4]=="OggS")
					sound_file = new VorbisFile(filename);
				else throw new Exception("Unrecognized sound format '"~cast(char[])file[0..4]~"' for file '"~filename~"'.");
				delete file;
	
				// Determine OpenAL format
				if (sound_file.channels==1 && sound_file.bits==8)  		al_format = AL_FORMAT_MONO8;
				else if (sound_file.channels==1 && sound_file.bits==16) al_format = AL_FORMAT_MONO16;
				else if (sound_file.channels==2 && sound_file.bits==8)  al_format = AL_FORMAT_STEREO8;
				else if (sound_file.channels==2 && sound_file.bits==16) al_format = AL_FORMAT_STEREO16;
				else throw new Exception("Sound must be 8 or 16 bit and mono or stero format.");
	
				// Calculate the parameters for our buffers
				int one_second_size = (sound_file.bits/8)*sound_file.frequency*sound_file.channels;
				arcfl seconds = sound_file.size/cast(double)one_second_size;
				buffer_num = cast(int)(seconds*buffers_per_sec);
				buffer_size= one_second_size/buffers_per_sec;
				int sample_size = sound_file.channels*sound_file.bits/8;
				buffer_size = (buffer_size/sample_size)*sample_size;	// ensure a multiple of our sample size
				buffers.length = buffers_ref.length = buffer_num;	// allocate empty buffers
				
				soundFileList[filename] = this; 
				soundFileList.rehash; 
			}
			else
			{
				// set to one already loaded 
				this = soundFileList[filename]; 
			}
		}
	}

	/// Tell OpenAL to release the sound, close the file
	~this()
	{	
		if (soundInitialized)
		{
			freeBuffers(0, buffer_num);	// ensure every buffer is released
		}
	}

	/// Get the frequency of the sound (usually 22050 or 44100)
	uint getFrequency()	{	return sound_file.frequency; }

	/** Get a pointer to the array of OpenAL buffer id's used for this sound.
	 *  allocBuffers() and freeBuffers() are used to assign and release buffers from the sound source.*/
	uint[] getBuffers()
	{	return buffers;
	}

	/// Get the number of buffers this sound was divided into
	uint getBuffersLength()
	{	return buffers.length;
	}

	/// Get the number of buffers created for each second of this sound
	uint getBuffersPerSecond()
	{	return buffers_per_sec;
	}

	/// Get the length of the sound in seconds
	double getLength()
	{	return (8.0*sound_file.size)/(sound_file.bits*sound_file.frequency*sound_file.channels);
	}

	/// Return the size of the uncompressed sound data, in bytes.
	uint getSize()
	{	return sound_file.size;
	}

	/// Get the filename this Sound was loaded from.
	char[] getSource()
	{	return sound_file.source;
	}

	/// get buffers 
	uint[] getBuffers(int first, int last)
	{	first = first % buffers.length;
		last = last % buffers.length;

		// If we're wrapping around
		if (first > last)
			return buffers[first..length]~buffers[0..last];
		else
			return buffers[first..last];
	}

	/** Return an array of OpenAL Buffers starting at first.
	 *  This can accept buffers outside of the range of buffers and
	 *  will wrap them around to support easy looping. */
	void allocBuffers(int first, int number)
	{	
		if(!soundInitialized)
			return;
			
		// Loop through each of the buffers that will be returned
		for (int j=first; j<first+number; j++)
		{	// Allow inputs that are out of range to loop around
			int i = j % buffers.length;

			// If this buffer hasn't yet been bound
			if (buffers_ref[i]==0)
			{	// Generate a buffer
				alGenBuffers(1, &buffers[i]);
				//printf("Newly generated buffer %d is %d\n", i, buffers[i]);
				ubyte[] data = sound_file.getBuffer(i*buffer_size, buffer_size);
				alBufferData(buffers[i], al_format, &data[0], cast(ALsizei)data.length, getFrequency());
			}
			// Increment reference count
			buffers_ref[i]++;
		}
	}

	/** Mark the range of buffers for freeing.
	 *  This will decrement the reference count for each of the buffers
	 *  and will release it once it's at zero. */
	void freeBuffers(int first, int number)
	{	
		if(!soundInitialized)
			return;
			
		for (int j=first; j<first+number; j++)
		{	// Allow inputs that are out of range to loop around
			int i = j % buffers.length;

			// Decrement reference count
			if (buffers_ref[i]==0)
				continue;
			buffers_ref[i]--;

			// If this buffer has no references to it, delete it
			if (buffers_ref[i]==0)
			{	alDeleteBuffers(1, &buffers[i]);
				if (alIsBuffer(buffers[i]))
					throw new Exception("Sound buffer "~.toString(i)~" of '"~sound_file.source~
										"' could not be deleted; probably because it is in use.\n");
		}	}
	}

	/// Print useful information about the loaded sound file.
	void print()
	{	sound_file.print();
		printf("size of buffer: %d bytes\n", buffer_size);
		printf("number of buffers: %d bytes\n", buffer_num);
		printf("buffers per second: %d bytes\n", buffers_per_sec);
	}
}



/** BaseSoundFile is an abstract class for loading and seeking
 *  sound data in a multimedia file.  A file is opened and closed
 *  in its constructor / destructor and getBuffer() can be used for fetching any data.
 *  To add support for a new sound file format, create a class
 *  that inherits from BaseSoundFile and override its methods. */
private abstract class BaseSoundFile
{
	ubyte	channels;
	int		frequency;	// 22050hz, 44100hz?
	int		bits;		// 8bit, 16bit?
	int		size;		// in bytes
	char[]	source;
	char[][]comments;	// Header info from audio file (not used yet)

	/// Load the given file and parse its headers
	this(char[] filename)
	{	source = filename;
		//Log.write("Loading sound '" ~ filename ~ "'.");
	}

	/** Return a buffer of uncompressed sound data.
	 *  Both parameters are measured in bytes. */
	ubyte[] getBuffer(int offset, int size)
	{
		arc.log.write("soundfx", "getBuffer()", "fatal", "Abstract Class BaseSoundFile does not implement 'getBuffer'"); 
		assert(0); 
		return null; 
	}

	/// Print useful information about the loaded sound file.
	void print()
	{	printf("Sound: '%.*s'\n", source);
		printf("channels: %d\n", channels);
		printf("sample rate: %dhz\n", frequency);
		printf("sample bits: %d\n", bits);
		printf("sample length: %d bytes\n", size);
		printf("sample length: %f seconds\n", (8.0*size)/(bits*frequency*channels));
	}
}


/// A Wave implementation of BaseSoundFile
private class WaveFile : BaseSoundFile
{
	MmFile	file;

	/// Open a wave file and store attributes from its headers
	this(char[] filename)
	{	
		super(filename);
		file = new MmFile(filename);

		// First 4 bytes of Wave file should be "RIFF"
		if (file[0..4] != "RIFF")
			throw new Exception("'"~filename~"' is not a RIFF file.");
		// Skip size value (4 bytes)
		if (file[8..12] != "WAVE")
			throw new Exception("'"~filename~"' is not a WAVE file.");
		// Skip "fmt ", format length, format tag (10 bytes)
		channels 	= (cast(ushort[])file[22..24])[0];
		frequency	= (cast(uint[])file[24..28])[0];
		// Skip average bytes per second, block align, bytes by capture (6 bytes)
		bits		= (cast(ushort[])file[34..36])[0];
		// Skip 'data' (4 bytes)
		size		= (cast(uint[])file[40..44])[0];
	}

	/// Free the file we loaded
	~this()
	{	
		//delete file;
	}

	/** Return a buffer of uncompressed sound data.
	 *  Both parameters are measured in bytes. */
	ubyte[] getBuffer(int offset, int _size)
	{	if (offset+_size > size)
			return null;
		return cast(ubyte[])file[(44+offset)..(44+offset+_size)];
	}

}

/// An Ogg Vorbis implementation of BaseSoundFile
private class VorbisFile : BaseSoundFile
{
	OggVorbis_File vf;		// struct for our open ov file.
	int current_section;	// used interally by ogg vorbis
	FILE *file;
	ubyte[] buffer;			// used for returning data

	/// Open an ogg vorbis file and store attributes from its headers
	this(char[] filename)
	{	
		super(filename);

		// Open the file
		file = fopen(toStringz(filename), "rb");
		if(ov_open(file, &vf, null, 0) < 0)
			throw new Exception("'"~filename~"' is not an Ogg Vorbis file.\n");
		vorbis_info *vi = ov_info(&vf, -1);

		// Get relevant data from the file
		channels = vi.channels;
		frequency = vi.rate;
		bits = 16;	// always 16-bit for ov?
		size = ov_pcm_total(&vf, -1)*(bits/8)*channels;
	}

	/// Free memory and close file
	~this()
	{	ov_clear(&vf);
		fclose(file);
		//delete buffer;
	}

	/** Return a buffer of uncompressed sound data.
	 *  Both parameters are measured in bytes. */
	ubyte[] getBuffer(int offset, int _size)
	{	if (offset+_size > size)
			return null;
		ov_pcm_seek(&vf, offset/(bits/8)/channels);
		buffer.length = _size;
		long ret = 0;
		while (ret<_size)	// because it may take several requests to fill our buffer
			ret += ov_read(&vf, cast(byte*)buffer[ret..length], _size-ret, 0, 2, 1, &current_section);
		return buffer;
	}
    
}

private
{
    // handle missing OpenAL functions 
    bool handleMissingOpenAL(char[] libname, char[] procName)
    {
       /// OpenAL stuff not required by arclib
       if(procName.cmp("aluF2L") == 0)
          return true; 

       if(procName.cmp("aluF2S") == 0)
          return true; 

       if(procName.cmp("aluCrossproduct") == 0)
          return true; 

       if(procName.cmp("aluDotproduct") == 0)
          return true; 

       if(procName.cmp("aluNormalize") == 0)
          return true; 

       if(procName.cmp("aluMatrixVector") == 0)
          return true; 

       if(procName.cmp("aluCalculateSourceParameters") == 0)
          return true; 

       if(procName.cmp("aluMixData") == 0)
          return true; 

       if(procName.cmp("aluSetReverb") == 0)
          return true; 

       if(procName.cmp("aluReverb") == 0)
          return true; 
    }
    
    // load up derelict functions from dll/so
    void loadDerelict()
    {
		try {
			Derelict_SetMissingProcCallback(&handleMissingOpenAL);
			DerelictAL.load(); 
			//DerelictALU.load();
			DerelictOgg.load(); 
			DerelictVorbis.load(); 
			DerelictVorbisFile.load();
		} // try

		// h
		catch (Exception e) {
			e.print();
			exit(0);
		} // catch
    }
    
    // unload derelict from mem 
    void unloadDerelict()
    {
		DerelictAL.unload(); 
		//DerelictALU.unload();
		DerelictOgg.unload(); 
		DerelictVorbis.unload(); 
		DerelictVorbisFile.unload();
    }
    
}

private 
{
	// list of soundfiles that are already loaded 
	SoundFile[char[]] soundFileList;
	
	// whether sound is 'on' or not
	bool soundOn = true;
	
	// whether sound has been initialized properly
	bool soundInitialized = false;
}

