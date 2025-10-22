<?php

namespace Aws\Endpoint;

/**
 * Provides endpoints based on an endpoint pattern configuration array.
 */
class PatternEndpointProvider
{
    /** @var array */
    private $patterns;

    /**
     * @param array $patterns Hash of endpoint patterns mapping to endpoint
     *                        configurations.
     */
    public function __construct(array $patterns)
    {
        $this->patterns = $patterns;
    }

    public function __invoke(array $args = [])
    {
        $service = $args['service'] ?? '';
        $region = $args['region'] ?? '';
        $keys = ["{$region}/{$service}", "{$region}/*", "*/{$service}", '*/*'];

        foreach ($keys as $key) {
            if (isset($this->patterns[$key])) {
                return $this->expand(
                    $this->patterns[$key],
                    $args['scheme'] ?? 'https',
                    $service,
                    $region
                );
            }
        }

        return null;
    }

    private function expand(array $config, $scheme, $service, $region)
    {
        $config['endpoint'] = $scheme . '://'
            . strtr($config['endpoint'], [
                '{service}' => $service,
                '{region}' => $region
            ]);

        return $config;
    }
}
