public class Forecast {
    private Day[] days;

    public Forecast (Json.Array forecast) {
        days = new Day[4];
        parse_forecast (forecast);
    }

    public Day get_day (int num_day) {
        return this.days[num_day];
    }

    public Day[] get_all_days () {
        return this.days;
    }

    public void parse_forecast (Json.Array forecast_data) {
        var util = new WeatherUtil ();
        var temp_day = forecast_data.get_element (0).get_object ();
        var cur_day = util.get_weekday (temp_day);
        var i = 0;
        days[i] = new Day (temp_day, false);
        //TODO make this a for size loop
        forecast_data.foreach_element (() => {
            var ele = this;
            if (cur_day != util.get_weekday (ele) || days[i].is_full ()) {
                days[++i] = new Day (ele, false);
            }
            days[i].fill_hour (ele);
        });
    }
}
