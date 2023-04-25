import { Inter } from 'next/font/google'

import {
  useQuery,
  useMutation,
  useQueryClient,
} from '@tanstack/react-query'

const inter = Inter({ subsets: ['latin'] })

export default function Question() {
  const handleSubmit = (e) => {
    console.log('submitting...', e);
  }

  return (
    <main
      className={`flex h-screen flex-col items-center justify-between p-24 ${inter.className}`}
    >
      <div className="bg-white py-16 sm:py-24">
        <div className="mx-auto max-w-7xl sm:px-6 lg:px-8">
          <div className="relative isolate overflow-hidden px-6 py-24 sm:rounded-3xl sm:px-24 xl:py-32">
            <h2 className="mx-auto mt-2 max-w-xl text-center text-lg leading-8 text-gray-900 font-bold">
              AI-powered book summarization. Ask it a question.
            </h2>
            <form onSubmit={handleSubmit} className="mx-auto mt-5 max-w-md gap-x-4">
              <label htmlFor="question" className="sr-only">
                Question
              </label>
              <div>
                <textarea
                  name="question"
                  required
                  maxLength={500}
                  rows={3}
                  style={{ resize: 'none' }}
                  className="w-full flex-auto rounded-md border-solid border border-gray-100 bg-white/5 px-3.5 py-2 text-gray-900 shadow-md ring-2 ring-inset ring-white/10 focus:ring-2 focus:ring-inset focus:ring-white sm:text-sm sm:leading-6"
                  placeholder="What do you think the authors intention was in writing this book?"
                />
              </div>

              <button type="submit" className="w-24 mt-4 rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
                Ask
              </button>
            </form>
            <svg
              viewBox="0 0 1024 1024"
              className="absolute left-1/2 top-1/2 -z-10 h-[64rem] w-[64rem] -translate-x-1/2"
              aria-hidden="true"
            >
              <circle cx={512} cy={512} r={512} fill="url(#759c1415-0410-454c-8f7c-9a820de03641)" fillOpacity="0.7" />
            </svg>
          </div>
        </div>
      </div>
    </main>
  )
}
