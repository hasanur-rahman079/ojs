<?php

namespace Aws\EndpointV2\Ruleset;

use Aws\Exception\UnresolvedEndpointException;

/**
 * Houses properties of an individual parameter definition.
 */
class RulesetParameter
{
    /** @var string */
    private $name;

    /** @var string */
    private $type;

    /** @var string */
    private $builtIn;

    /** @var string */
    private $default;

    /** @var array */
    private $required;

    /** @var string */
    private $documentation;

    /** @var boolean */
    private $deprecated;

    public function __construct($name, array $definition)
    {
        $type = ucfirst($definition['type']);
        if ($this->isValidType($type)) {
            $this->type = $type;
        } else {
            throw new UnresolvedEndpointException(
                'Unknown parameter type ' . "`{$type}`" .
                '. Parameters must be of type `String` or `Boolean`.'
            );
        }
        $this->name = $name;
        $this->builtIn = $definition['builtIn'] ?? null;
        $this->default = $definition['default'] ?? null;
        $this->required = $definition['required'] ?? false;
        $this->documentation = $definition['documentation'] ?? null;
        $this->deprecated = $definition['deprecated'] ?? false;
    }

    /**
     */
    public function getName()
    {
        return $this->name;
    }

    /**
     */
    public function getType()
    {
        return $this->type;
    }

    /**
     */
    public function getBuiltIn()
    {
        return $this->builtIn;
    }

    /**
     */
    public function getDefault()
    {
        return $this->default;
    }

    /**
     * @return boolean
     */
    public function getRequired()
    {
        return $this->required;
    }

    /**
     * @return string
     */
    public function getDocumentation()
    {
        return $this->documentation;
    }

    /**
     * @return boolean
     */
    public function getDeprecated()
    {
        return $this->deprecated;
    }

    /**
     * Validates that an input parameter matches the type provided in its definition.
     *
     * @throws InvalidArgumentException
     */
    public function validateInputParam($inputParam)
    {
        $typeMap = [
            'String' => 'is_string',
            'Boolean' => 'is_bool'
        ];

        if ($typeMap[$this->type]($inputParam) === false) {
            throw new UnresolvedEndpointException(
                "Input parameter `{$this->name}` is the wrong type. Must be a {$this->type}."
            );
        }

        if ($this->deprecated) {
            $deprecated = $this->deprecated;
            $deprecationString = "{$this->name} has been deprecated ";
            $msg = $deprecated['message'] ?? null;
            $since = $deprecated['since'] ?? null;

            if (!is_null($since)) {
                $deprecationString = $deprecationString
                    . 'since ' . $since . '. ';
            }
            if (!is_null($msg)) {
                $deprecationString = $deprecationString . $msg;
            }

            trigger_error($deprecationString, E_USER_WARNING);
        }
    }

    private function isValidType($type)
    {
        return in_array($type, ['String', 'Boolean']);
    }
}
