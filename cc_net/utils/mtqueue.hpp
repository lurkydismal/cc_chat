#pragma once

#include "common.hpp"

namespace cc {
    namespace net {
        template< typename T >
        class mtqueue {
        protected:
            std::deque< T > queue;
            std::mutex mutex_queue;
            std::mutex mutex_wait;
            std::condition_variable cv;

        public:
            mtqueue() = default;
            mtqueue( const mtqueue& ) = delete;

            virtual ~mtqueue() {
                this->clear();
            }

            const T& front( void ) {
                std::scoped_lock lock( mutex_queue );

                return ( queue.front() );
            }

            const T& back( void ) {
                std::scoped_lock lock( mutex_queue );

                return ( queue.back() );
            }

            void push_front( const T& item ) {
                std::scoped_lock lock( mutex_queue );
                queue.emplace_front( std::move( item ) );
                cv.notify_one();
            }

            void push_back( const T& item ) {
                std::scoped_lock lock( mutex_queue );
                queue.emplace_back( std::move( item ) );
                cv.notify_one();
            }

            T pop_front( void ) {
                std::scoped_lock lock( mutex_queue );
                auto temp = std::move( queue.front() );
                queue.pop_front();

                return ( temp );
            }

            T pop_back( void ) {
                std::scoped_lock lock( mutex_queue );
                auto temp = std::move( queue.back() );
                queue.pop_back();

                return ( temp );
            }

            bool empty( void ) {
                std::scoped_lock lock( mutex_queue );

                return ( queue.empty() );
            }

            size_t size( void ) {
                std::scoped_lock lock( mutex_queue );

                return ( queue.size() );
            }

            void clear( void ) {
                std::scoped_lock lock( mutex_queue );
                queue.clear();
            }

            void wait( void ) {
                if ( empty() ) {
                    std::unique_lock< std::mutex > ul( mutex_wait );
                    cv.wait( ul );
                }
            }
        };
    }
}
