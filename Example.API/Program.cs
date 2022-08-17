using Example.API.Configuration;
using Example.API.Controllers;
using Microsoft.Extensions.Options;

namespace Example.API
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Host.ConfigureAppConfiguration((hostingContext, config) =>
            {
                config
                    .AddJsonFile("appSettings.json", optional: true, reloadOnChange: true)
                    .AddEnvironmentVariables();
            });
            builder.Services.AddApplicationInsightsTelemetry();
            builder.Services.AddOptions();

            builder.Services.Configure<SomeSectionConfig>(builder.Configuration.GetSection("SomeSection")).AddSingleton<SomeSectionConfig>((sp =>
            {
#pragma warning disable CS8602 // Dereference of a possibly null reference.
                return sp.GetService<IOptions<SomeSectionConfig>>().Value;
#pragma warning restore CS8602 // Dereference of a possibly null reference.
            }));

            builder.Services.Configure<StorageAccountConfig>(builder.Configuration.GetSection("StorageAccount")).AddSingleton<StorageAccountConfig>((sp =>
            {
#pragma warning disable CS8602 // Dereference of a possibly null reference.
                return sp.GetService<IOptions<StorageAccountConfig>>().Value;
#pragma warning restore CS8602 // Dereference of a possibly null reference.
            }));

            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();
            builder.Services.AddHealthChecks().AddCheck<ExampleHealthCheck>("Example");

            var app = builder.Build();

            app.UseSwagger();
            app.UseSwaggerUI();

            app.UseAuthorization();

            app.MapControllers();
            app.MapHealthChecks("/health");

            app.Run();
        }
    }
}