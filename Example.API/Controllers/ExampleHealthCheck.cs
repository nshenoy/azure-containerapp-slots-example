using Example.API.Configuration;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Example.API.Controllers
{
    public class ExampleHealthCheck : IHealthCheck
    {
        private readonly SomeSectionConfig someSectionConfig;
        private readonly StorageAccountConfig storageAccountConfig;

        public ExampleHealthCheck(SomeSectionConfig someSectionConfig, StorageAccountConfig storageAccountConfig)
        {
            this.someSectionConfig = someSectionConfig;
            this.storageAccountConfig = storageAccountConfig;
        }
        public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            var isHealthy = false;

            if ( string.IsNullOrEmpty(this.someSectionConfig.SomeSensitiveSetting)
                || string.IsNullOrEmpty(this.someSectionConfig.SomeOtherSetting)
                || string.IsNullOrEmpty(this.storageAccountConfig.ConnectionString))
            {
                isHealthy = false;
            }
            else
            {
                isHealthy = true;
            }

            if (isHealthy)
            {
                return Task.FromResult(HealthCheckResult.Healthy("Application is configured correctly"));
            }
            else
            {
                return Task.FromResult(HealthCheckResult.Unhealthy("Application is not configured corectly"));
            }
        }
    }
}
