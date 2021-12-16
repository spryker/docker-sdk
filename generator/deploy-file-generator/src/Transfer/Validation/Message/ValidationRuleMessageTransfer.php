<?php
/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DeployFileGenerator\Transfer\Validation\Message;

class ValidationRuleMessageTransfer
{
    /**
     * @var string
     */
    protected $ruleName;

    /**
     * @var string
     */
    protected $message;

    /**
     * @return string
     */
    public function getRuleName(): string
    {
        return $this->ruleName;
    }

    /**
     * @param string $ruleName
     *
     * @return $this
     */
    public function setRuleName(string $ruleName)
    {
        $this->ruleName = $ruleName;

        return $this;
    }

    /**
     * @return string
     */
    public function getMessage(): string
    {
        return $this->message;
    }

    /**
     * @param string $message
     *
     * @return $this
     */
    public function setMessage(string $message)
    {
        $this->message = $message;

        return $this;
    }
}
