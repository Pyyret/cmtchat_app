enum RepositoryStatus { unknown, authenticated, unauthenticated }

/*
class Repository {

  const Repository({
    required TodosApi todosApi,

  }) : _todosApi = todosApi;

  final User;

  final TodosApi _todosApi;
}




class WeatherRepository {
  WeatherRepository({OpenMeteoApiClient? weatherApiClient})
      : _weatherApiClient = weatherApiClient ?? OpenMeteoApiClient();

  final OpenMeteoApiClient _weatherApiClient;

  Future<Weather> getWeather(String city) async {
    final location = await _weatherApiClient.locationSearch(city);
    final weather = await _weatherApiClient.getWeather(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    return Weather(
      temperature: weather.temperature,
      location: location.name,
      condition: weather.weatherCode.toInt().toCondition,
    );
  }
}

 */