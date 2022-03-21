#pragma once
#include "common.hpp"

namespace cc
{
    namespace net
    {
        template<typename T>
        class mtqueue
        {
        public:
            mtqueue() = default;
            mtqueue(const mtqueue&) = delete;
            virtual ~mtqueue()
            {
                this->clear();
            }
        public:
            const T& front() const
            {
                std::scoped_lock lock(mutex_queue);
                return queue.front();
            }

            const T& back() const
            {
                std::scoped_lock lock(mutex_queue);
                return queue.back();
            }

            void push_front(const T& item)
            {
                std::scoped_lock lock(mutex_queue);
                queue.emplace_front(std::move(item));

                cv.notify_one();
            }

            void push_back(const T& item)
            {
                std::scoped_lock lock(mutex_queue);
                queue.emplace_back(std::move(item));

                cv.notify_one();
            }

            T pop_front()
            {
                std::scoped_lock lock(mutex_queue);
                auto temp = std::move(queue.front());
                queue.pop_front();
                return temp;
            }

            T pop_back()
            {
                std::scoped_lock lock(mutex_queue);
                auto temp = std::move(queue.back());
                queue.pop_back();
                return temp;
            }

            bool empty() const
            {
                std::scoped_lock lock(mutex_queue);
                return queue.empty();
            }

            size_t size() const
            {
                std::scoped_lock lock(mutex_queue);
                return queue.size();
            }

            void clear()
            {
                std::scoped_lock lock(mutex_queue);
                queue.clear();
            }

            void wait()
            {
                if (empty())
                {
                    std::unique_lock<std::mutex> ul(mutex_wait);
                    cv.wait(ul);
                }
            }
        protected:
            std::deque<T> queue;
            std::mutex mutex_queue;
            std::mutex mutex_wait;
            std::condition_variable cv;
        };
    }
}