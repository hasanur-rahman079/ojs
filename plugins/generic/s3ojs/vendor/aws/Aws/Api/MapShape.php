<?php

namespace Aws\Api;

/**
 * Represents a map shape.
 */
class MapShape extends Shape
{
    /** @var Shape */
    private $value;

    /** @var Shape */
    private $key;

    public function __construct(array $definition, ShapeMap $shapeMap)
    {
        $definition['type'] = 'map';
        parent::__construct($definition, $shapeMap);
    }

    /**
     * @throws \RuntimeException if no value is specified
     *
     * @return Shape
     */
    public function getValue()
    {
        if (!$this->value) {
            if (!isset($this->definition['value'])) {
                throw new \RuntimeException('No value specified');
            }

            $this->value = Shape::create(
                $this->definition['value'],
                $this->shapeMap
            );
        }

        return $this->value;
    }

    /**
     * @return Shape
     */
    public function getKey()
    {
        if (!$this->key) {
            $this->key = isset($this->definition['key'])
                ? Shape::create($this->definition['key'], $this->shapeMap)
                : new Shape(['type' => 'string'], $this->shapeMap);
        }

        return $this->key;
    }
}
