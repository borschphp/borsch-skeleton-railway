<?php

namespace App\Middleware;

use Borsch\Router\RouteResultInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * Class DispatchMiddleware
 *
 * Process a RouteResult, else delegate to the next middleware.
 *
 * @package App\Middleware
 */
class DispatchMiddleware implements MiddlewareInterface
{

    /**
     * @inheritDoc
     */
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $route_result = $request->getAttribute(RouteResultInterface::class);
        if (!$route_result) {
            return $handler->handle($request);
        }

        return $route_result->process($request, $handler);
    }
}
