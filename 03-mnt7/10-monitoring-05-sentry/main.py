import sentry_sdk
sentry_sdk.init(
    "https://8b35bda7b8ca411bb89022a10d303562@o1129210.ingest.sentry.io/6172849",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0,
    environment='stable',
    release='app-1.0.0'
)

if __name__ == '__main__':
    division_by_zero = 1 / 0
