import com.luckycatlabs.sunrisesunset.SunriseSunsetCalculator;
import com.luckycatlabs.sunrisesunset.dto.Location;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class Main
{
	public static void main( String[] args )
		throws Exception
	{
		Calendar now = Calendar.getInstance();

		if( args.length > 0 )
		{
			SimpleDateFormat sdf = new SimpleDateFormat( "yyyy-MM-dd-HH" );
			now.setTime( sdf.parse( args[0] ) );
		}

		Location location = new Location( "42.9745", "-82.4066" );
		SunriseSunsetCalculator calculator = new SunriseSunsetCalculator( location, "America/New_York" );
		Calendar sunrise = calculator.getOfficialSunriseCalendarForDate( now );
		sunrise.add( Calendar.HOUR, -1 );

		Calendar sunset = calculator.getOfficialSunsetCalendarForDate( now );
		sunset.add( Calendar.HOUR, 1 );

		System.exit( sunrise.before( now ) && sunset.after( now ) ? 0 : 1 );
	}
}

