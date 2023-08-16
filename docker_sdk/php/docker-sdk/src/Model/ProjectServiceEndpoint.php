<?php

/**
 * This file is part of the Spryker Suite.
 * For full license information, please view the LICENSE file that was distributed with this source code.
 */

namespace DockerSDK\Model;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ProjectServiceEndpoint extends Model
{
    protected $table = 'project_service_endpoints';

    protected $fillable = [
        'project_id',
        'service_name',
        'endpoint',
    ];

    public $timestamps = false;

    /**
     * @return BelongsTo
     */
    public function project(): BelongsTo
    {
        return $this->belongsTo(Project::class);
    }
}
